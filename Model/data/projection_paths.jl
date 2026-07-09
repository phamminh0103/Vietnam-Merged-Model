# ==============================================================================
# Projection paths
#
# Exogenous levels grow at compound rates from their base-year values;
# parameters are held constant (plus any rate adjustment) over the horizon.
# ==============================================================================

constant_path(x, horizon) = fill(Float64(x), horizon)

compound_path(x0, growth, horizon) = x0 .* (1 + growth) .^ (1:horizon)

function build_projection_paths(base::BaseYearState, assumptions; horizon::Int)
    E_growth = assumptions.exchange_rate_growth
    PD_growth = assumptions.domestic_price_growth

    # Foreign prices keep the real exchange rate constant.
    foreign_price_growth = (1 + PD_growth) / (1 + E_growth) - 1

    # Sectoral growth rates: (:gamma, sector) for GDP, (:xgr, sector) for exports.

    growth = Dict(
        (name, sector) => constant_path(assumptions[Symbol(sector, suffix)], horizon)
        for (name, suffix) in pairs((gamma = :_gdp_growth, xgr = :_export_growth))
        for sector in SAM_SECTORS
    )

    # Exogenous levels: base-year value => growth rate.

    growth_rates = (
        E = E_growth,
        PD = PD_growth,
        MPI = foreign_price_growth,
        XPI = foreign_price_growth,

        GT = PD_growth,
        TG = assumptions.government_revenue_growth,
        IVG = assumptions.government_investment_growth,
        NDDG = assumptions.government_domestic_debt_growth,

        NFP = assumptions.net_factor_payments_growth,
        NTRG = assumptions.government_transfers_growth,
        NTRP = assumptions.private_transfers_growth,
        FDI = assumptions.foreign_direct_investment_growth,
    )

    paths = Dict(
        name => compound_path(base.values[name], rate, horizon)
        for (name, rate) in pairs(growth_rates)
    )

    # Behavioural parameters, constant over the horizon.

    c = base.calibrated

    parameters = Dict(
        :b => constant_path(c[:b_calibrated], horizon),
        :d => constant_path(assumptions.reserve_change_import_change_response, horizon),
        :g => constant_path(c[:g], horizon),
        :k0 => constant_path(c[:k0], horizon),
        :m0 => constant_path(c[:m0], horizon),
        :v => constant_path(c[:v], horizon),

        :k1 => constant_path(assumptions.investment_growth_coefficient, horizon),
        :m1 => constant_path(assumptions.import_gdp_elasticity, horizon),
        :m2 => constant_path(assumptions.import_real_exchange_rate_elasticity, horizon),

        :irdg => constant_path(
            c[:irdg] + assumptions.government_domestic_rate_adjustment, horizon),
        :irfg => constant_path(
            c[:irfg] + assumptions.government_foreign_rate_adjustment, horizon),
        :irfp => constant_path(
            c[:irfp] + assumptions.private_foreign_rate_adjustment, horizon),
    )

    return (; growth, paths, parameters)
end