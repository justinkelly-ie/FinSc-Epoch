module Epoch.Trajectory

import public Core
import Data.Vect
import Data.List
import Epoch.ChromogeometryLaw
import Epoch.GohStreamTransducer
import Epoch.ExpansionCollapse

%default total

--------------------------------------------------------------------------------
-- 1. 37-EPOCH COSMIC TRAJECTORY SIMULATION
--------------------------------------------------------------------------------

||| Helper to recursively simulate N epoch steps.
public export
simulateEpochSteps : Nat -> EpochState -> List EpochState
simulateEpochSteps 0 st = [st]
simulateEpochSteps (S k) st = st :: simulateEpochSteps k (advanceEpochState st)

||| Simulates exact 37-epoch trajectory starting from initial state.
public export
simulate37Epochs : EpochState -> List EpochState
simulate37Epochs initSt = simulateEpochSteps 36 initSt

||| Evaluates initial Genesis state bootstrapped from empty multiset ZeroM.
public export
initBootstrapEpoch : EpochState
initBootstrapEpoch = initGenesisEpoch

||| Direct step advance over N epochs.
public export
advanceN : Nat -> EpochState -> EpochState
advanceN 0 st = st
advanceN (S k) st = advanceN k (advanceEpochState st)

||| Evaluates the final Epoch 37 state from Genesis bootstrap.
public export
getEpoch37State : EpochState
getEpoch37State = advanceN 36 initGenesisEpoch


--------------------------------------------------------------------------------
-- 2. PRIMORIAL 210 BUDGET CLOSURE PROOF WITNESSES
--------------------------------------------------------------------------------

||| Verifies that Genesis Epoch 1 starts from empty multiset ZeroM.
public export
0 verifyBootstrapFromEmptyMultiset : Epoch.ExpansionCollapse.initGenesisEpoch.darkMatterLedger = ZeroM
verifyBootstrapFromEmptyMultiset = Refl

||| Audits Primorial 210 budget closure at Epoch 37 (VM=27, DE=128, DM=55 -> Total=210).
public export
auditPrimorial210BudgetProof : Bool
auditPrimorial210BudgetProof =
  let st37 = getEpoch37State
      vm = st37.visibleBaryons
      de = st37.darkEnergy
      dm = countTotalDarkLaws st37.darkMatterLedger
  in (vm + de + dm) == 210

--------------------------------------------------------------------------------
-- 3. MULTI-CYCLE CYCLIC UNIVERSE TRAJECTORY SIMULATION
--------------------------------------------------------------------------------

||| Advances N steps through the cyclic universe state machine using reboundCyclicEpoch.
public export
advanceCyclicN : Nat -> EpochState -> EpochState
advanceCyclicN 0 st = st
advanceCyclicN (S k) st = advanceCyclicN k (reboundCyclicEpoch st)

||| Simulates N steps of continuous cyclic cosmic trajectory.
public export
simulateCyclicEpochs : Nat -> EpochState -> List EpochState
simulateCyclicEpochs 0 st = [st]
simulateCyclicEpochs (S k) st = st :: simulateCyclicEpochs k (reboundCyclicEpoch st)

||| Audit verifying cyclic rebound resets a saturated Epoch 37 state to Epoch 1.
public export
auditCyclicReboundPeriodicity : Bool
auditCyclicReboundPeriodicity = (reboundCyclicEpoch getEpoch37State).epochNumber == 1

public export
0 verifyCyclicReboundPeriodicity : Epoch.Trajectory.auditCyclicReboundPeriodicity = True
verifyCyclicReboundPeriodicity = Refl
