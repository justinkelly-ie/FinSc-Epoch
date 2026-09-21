module Epoch.ExpansionCollapse

import public Core
import public Cosmology
import public Math.Cosmology.GaloisAdjunction
import Epoch.ChromogeometryLaw

%default total

--------------------------------------------------------------------------------
-- 1. COSMIC EPOCH STATE & ACCUMULATION STATE MACHINE
--------------------------------------------------------------------------------

||| Full cosmological epoch state wrapping visible baryons, dark energy, and DM law ledger.
public export
record EpochState where
  constructor MkEpochState
  epochNumber      : Nat
  visibleBaryons   : Nat
  darkEnergy       : Nat
  darkMatterLedger : ChromogeometryLawLedger

public export
Show EpochState where
  show (MkEpochState ep vm de ledger) =
    "Epoch " ++ show ep ++ " [VM=" ++ show vm ++ ", DE=" ++ show de ++ 
    ", DM=" ++ show (countTotalDarkLaws ledger) ++ "]"

||| Genesis Empty Vacuum Initial State (Epoch 1 bootstrapped from ZeroM).
public export
initGenesisEpoch : EpochState
initGenesisEpoch = MkEpochState 1 0 (powerNat 2 7) emptyLawLedger

||| Advances the epoch state by executing expansion (f_*) followed by collapse (f^*) rebound,
||| accumulating Chromogeometric law fingerprints in the dark matter ledger.
public export
advanceEpochState : EpochState -> EpochState
advanceEpochState (MkEpochState ep vm de ledger) =
  let nextEp    = S ep
      nextVM    = vmMaxelsAtEpoch nextEp
      newLedger = accumulateLawsForEpoch ep ledger
  in MkEpochState nextEp nextVM de newLedger

||| Static proof witness verifying epoch counter strictly increments on each collapse.
public export
0 verifyEpochIncrement : (st : EpochState) -> (advanceEpochState st).epochNumber = S (st.epochNumber)
verifyEpochIncrement (MkEpochState ep _ _ _) = Refl

--------------------------------------------------------------------------------
-- 2. GALOIS ADJUNCTION CYCLIC REBOUND (EPOCH 37 -> 1 HORIZON PULLBACK)
--------------------------------------------------------------------------------

||| Evaluates cyclic universe rebound via Galois pullback f^*:
||| When epoch state reaches or exceeds total capacity saturation (>= 210 at Epoch 37),
||| it pulls back into the Genesis Vacuum State (Epoch 1), otherwise advancing normally.
public export
reboundCyclicEpoch : EpochState -> EpochState
reboundCyclicEpoch st =
  let totalCap = st.visibleBaryons + st.darkEnergy + countTotalDarkLaws st.darkMatterLedger
  in if natLTE 210 totalCap then
       initGenesisEpoch
     else
       advanceEpochState st

||| Audit verifying cyclic rebound resets a saturated Epoch 37 state (210 capacity) to Genesis Epoch 1.
public export
auditCyclicReboundVacuumReset : Bool
auditCyclicReboundVacuumReset = (reboundCyclicEpoch (MkEpochState 37 27 128 (AddM EllipticRed (intToBoxInt 55) ZeroM))).epochNumber == 1

public export
0 verifyCyclicReboundVacuumReset : Epoch.ExpansionCollapse.auditCyclicReboundVacuumReset = True
verifyCyclicReboundVacuumReset = Refl
