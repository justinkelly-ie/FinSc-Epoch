module Epoch.ChromogeometryLaw

import public Core
import public Cosmology

%default total

--------------------------------------------------------------------------------
-- 1. COSMIC EPOCH METRIC LAW ACCUMULATION POLICY
--------------------------------------------------------------------------------

||| Evaluates whether the dark matter ledger has reached the dual-mode phase transition (>= 17 laws accumulated or step >= 18).
public export
isDualModePhase : Nat -> ChromogeometryLawLedger -> Bool
isDualModePhase ep ledger = natLTE 18 ep || countTotalDarkLaws ledger >= 17

||| Accumulates Chromogeometric law fingerprints at epoch contraction step ep.
||| Dynamically evaluates phase transition: single-mode (EllipticRed) when < 17 laws,
||| dual-mode (EllipticRed + HyperbolicGreen) when >= 17 laws accumulated.
public export
accumulateLawsForEpoch : Nat -> ChromogeometryLawLedger -> ChromogeometryLawLedger
accumulateLawsForEpoch ep ledger =
  if isDualModePhase ep ledger then
    AddM EllipticRed (intToBoxInt 1) (AddM HyperbolicGreen (intToBoxInt 1) ledger)
  else
    AddM EllipticRed (intToBoxInt 1) ledger
