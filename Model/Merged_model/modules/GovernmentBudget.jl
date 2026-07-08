module GovernmentBudget
import JuMP
using SquareModels

function define_equations(db, vars; proj)
    (; BRG, CG, DCG, INDG, INFG, NDDG, NFDG,
       X, GT, IVG, NTRG, TG, E, PD, XPI,
       g, irdg, irfg) = vars

    return @block db begin
        # =====================================================================
        # Equations (14)-(16): Government budget and debt
        # =====================================================================

        BRG[t = proj],
            BRG[t] ==
                PD[t] * (CG[t] + IVG[t]) +
                (GT[t] - TG[t]) +
                INDG[t] +
                E[t] * (INFG[t] - NTRG[t])                    # Eq. 14

        DCG[t = proj],
            BRG[t] ==
                E[t] * (NFDG[t] - NFDG[t - 1]) +
                (NDDG[t] - NDDG[t - 1]) +
                (DCG[t] - DCG[t - 1])                         # Eq. 15

        NFDG[t = proj],
            NFDG[t] ==
                g[t] * XPI[t] * X[t]                          # Eq. 16

        # =====================================================================
        # Equations (27)-(28): Government interest payments
        # =====================================================================

        INDG[t = proj],
            INDG[t] ==
                irdg[t] * NDDG[t - 1]                         # Eq. 27

        INFG[t = proj],
            INFG[t] ==
                irfg[t] * NFDG[t - 1]                         # Eq. 28
    end
end

end