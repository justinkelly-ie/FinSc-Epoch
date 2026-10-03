module Stage1.Epoch.ChromogeometryLaw

import public Stage0.BoxInt
import public Stage0.Multiset
import public Stage1.MetricSignature
import public Stage0.Cosmology.MetricLawLedger
import public Cosmology

%default total

--------------------------------------------------------------------------------
-- 1. COSMIC EPOCH METRIC LAW ACCUMULATION POLICY
--------------------------------------------------------------------------------

||| Evaluates whether the dark matter ledger has reached the dual-mode phase transition (>= 17 laws accumulated or step >= 18).
public export
isDualModePhase : Nat -> ChromogeometryLawLedger -> Bool
isDualModePhase ep ledger = 18 <= ep || countTotalDarkLaws ledger >= 17

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

--------------------------------------------------------------------------------
-- 2. CANONICAL MULTISET METRIC SIGNATURE ACCUMULATION POLICY
--------------------------------------------------------------------------------

||| Evaluates whether the cosmic metric ledger has reached the dual-mode phase transition.
public export
isDualModeMetricPhase : Nat -> CosmicMetricLedger -> Bool
isDualModeMetricPhase ep ledger = 18 <= ep || countMetricLedgerLaws ledger >= 17

||| Accumulates canonical MetricSignature records directly into a CosmicMetricLedger.
public export
accumulateMetricSignaturesForEpoch : Nat -> CosmicMetricLedger -> CosmicMetricLedger
accumulateMetricSignaturesForEpoch ep ledger =
  if isDualModeMetricPhase ep ledger then
    AddM ellipticSignature2D (intToBoxInt 1) (AddM hyperbolicSignature2D (intToBoxInt 1) ledger)
  else
    AddM ellipticSignature2D (intToBoxInt 1) ledger
