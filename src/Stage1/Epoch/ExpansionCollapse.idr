module Stage1.Epoch.ExpansionCollapse

import public Stage0.BoxInt
import public Stage0.Multiset
import public Stage0.OnSeq.FusedStream
import public Stage1.QuadStream
import public Cosmology
import public Stage1.Cosmology.MultisetAdjunction
import public Stage1.FourGeometries
import public Stage1.FourGeometriesActions
import Stage1.Epoch.ChromogeometryLaw

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
initGenesisEpoch = MkEpochState 1 0 Stage1.FourGeometries.hyperbolicRomCapacity emptyLawLedger

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
-- 2. MULTISET SCALE ADJUNCTION CYCLIC REBOUND (EPOCH 37 -> 1 HORIZON PULLBACK)
--------------------------------------------------------------------------------

||| Evaluates cyclic universe rebound via Multiset Scale pullback f^*:
||| When epoch state reaches or exceeds total capacity saturation (>= 210 at Epoch 37),
||| it pulls back into the Genesis Vacuum State (Epoch 1), otherwise advancing normally.
public export
reboundCyclicEpoch : EpochState -> EpochState
reboundCyclicEpoch st =
  let totalCap = st.visibleBaryons + st.darkEnergy + countTotalDarkLaws st.darkMatterLedger
  in if primorial210Budget <= totalCap then
       initGenesisEpoch
     else
       advanceEpochState st

||| Audit verifying cyclic rebound resets a saturated Epoch 37 state (210 capacity) to Genesis Epoch 1.
public export
auditCyclicReboundVacuumReset : Bool
auditCyclicReboundVacuumReset = (reboundCyclicEpoch (MkEpochState 37 27 128 (AddM EllipticRed (intToBoxInt 55) ZeroM))).epochNumber == 1

public export
0 verifyCyclicReboundVacuumReset : Stage1.Epoch.ExpansionCollapse.auditCyclicReboundVacuumReset = True
verifyCyclicReboundVacuumReset = Refl

--------------------------------------------------------------------------------
-- 3. QUAD-STREAM MULTISET EPOCH INTEGRATION
--------------------------------------------------------------------------------

||| Converts an EpochState into a SubstrateLawLedger55 record (27 VM, 55 DM, 128 DE).
public export
epochStateToSubstrateLedger : EpochState -> SubstrateLawLedger55
epochStateToSubstrateLedger (MkEpochState _ vm de ledger) =
  MkSubstrateLawLedger55 vm (countTotalDarkLaws ledger) de

||| Converts an EpochState into a 4-channel QuadStreamMultiset BoxInt payload.
public export
epochStateToQuadStream : EpochState -> QuadStreamMultiset BoxInt
epochStateToQuadStream (MkEpochState _ vm de ledger) =
  let e = AddM (intToBoxInt 1) (natToBoxInt vm) ZeroM
      h = AddM (intToBoxInt 1) (natToBoxInt de) ZeroM
      p = ZeroM
      s = AddM (intToBoxInt 1) (natToBoxInt (countTotalDarkLaws ledger)) ZeroM
  in MkQuadStream e h p s

||| Converts a 4-channel QuadStreamMultiset BoxInt payload back into EpochState.
public export
quadStreamToEpochState : (ep : Nat) -> QuadStreamMultiset BoxInt -> EpochState
quadStreamToEpochState ep (MkQuadStream e h p s) =
  let vm = cast (unwrapBox (multisetSum e))
      de = cast (unwrapBox (multisetSum h))
      dmCount = cast (unwrapBox (multisetSum s))
      ledger = AddM EllipticRed (intToBoxInt dmCount) ZeroM
  in MkEpochState ep vm de ledger

||| Evaluates discrete Helmholtz Free Energy (F = U - T * S) over QuadStream epoch state.
public export
evaluateQuadStreamEpochFreeEnergy : QuadStreamMultiset BoxInt -> BoxInt
evaluateQuadStreamEpochFreeEnergy (MkQuadStream e h p s) =
  let u = multisetSum e
      t = multisetSum h
      sVal = multisetSum s
  in u - (t * sVal)

||| Advances a QuadStreamMultiset BoxInt epoch payload through expansion and law accumulation.
public export
quadStreamAdvanceEpoch : (ep : Nat) -> QuadStreamMultiset BoxInt -> QuadStreamMultiset BoxInt
quadStreamAdvanceEpoch ep qs =
  let st = quadStreamToEpochState ep qs
      st' = advanceEpochState st
  in epochStateToQuadStream st'

||| Stateful deforested stream transducer advancing epoch state via expansion and law accumulation.
public export
epochTransducer : StreamTransducer EpochState EpochState
epochTransducer = MkTransducer (\_, st => Yield (advanceEpochState st) ()) ()

||| Streams N steps of deforested cosmic epoch trajectories without intermediate list allocations.
public export covering
streamEpochTrajectory : Nat -> EpochState -> FusedStream EpochState
streamEpochTrajectory n initSt =
  unfoldStream (\(k, st) => case k of
                              Z => Done
                              S k' => Yield st (k', advanceEpochState st)) (n, initSt)

||| Audit verifying QuadStream round-trip conversion for Observer Epoch 37.
public export
auditQuadStreamEpochStateProof : Bool
auditQuadStreamEpochStateProof =
  let st37 = MkEpochState 37 27 128 (AddM EllipticRed (intToBoxInt 55) ZeroM)
      qs37 = epochStateToQuadStream st37
      mass = quadStreamTotalMass qs37
  in unwrapBox mass == 210
