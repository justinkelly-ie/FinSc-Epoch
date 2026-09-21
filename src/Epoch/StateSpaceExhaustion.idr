module Epoch.StateSpaceExhaustion

import public Core
import public Cosmology
import public Epoch.ChromogeometryLaw
import public Epoch.ExpansionCollapse
import public Epoch.Trajectory

%default total

--------------------------------------------------------------------------------
-- 1. CHROMOGEOMETRIC MAXEL & BOXEL EXHAUSTION METRICS
--------------------------------------------------------------------------------

||| Tracks state space saturation across derived CapacityBudget partitions.
public export
record MaxelBoxelExhaustion where
  constructor MkExhaustion
  occupiedMaxels       : Nat
  activeBoxels         : Nat
  accumulatedDarkLaws  : Nat
  totalOccupiedBudget  : Nat

public export
showMaxelExhaustion : MaxelBoxelExhaustion -> String
showMaxelExhaustion ex =
  let b = observerEpoch37Budget
  in "State Space Saturation [VM Maxels = " ++ show ex.occupiedMaxels ++ "/" ++ show b.vmCapacity ++
     ", DE Boxels = " ++ show ex.activeBoxels ++ "/" ++ show b.deCapacity ++
     ", DM Laws = " ++ show ex.accumulatedDarkLaws ++ "/" ++ show b.dmCapacity ++
     " | Total = " ++ show ex.totalOccupiedBudget ++ "/" ++ show (totalCapacity b) ++ "]"

public export
Show MaxelBoxelExhaustion where
  show ex = showMaxelExhaustion ex

||| Evaluates state space saturation for a given epoch state.
public export
evalStateSpaceSaturation : EpochState -> MaxelBoxelExhaustion
evalStateSpaceSaturation st =
  let vm = st.visibleBaryons
      de = st.darkEnergy
      dm = countTotalDarkLaws st.darkMatterLedger
  in MkExhaustion vm de dm (vm + de + dm)

--------------------------------------------------------------------------------
-- 2. STATE SPACE EXHAUSTION PROOF WITNESSES
--------------------------------------------------------------------------------

||| Verifies that Epoch 1 starts with 0 dark laws (bootstrapped from ZeroM).
public export
0 verifyGenesisEmptyDarkLaws : (evalStateSpaceSaturation Epoch.ExpansionCollapse.initGenesisEpoch).accumulatedDarkLaws = 0
verifyGenesisEmptyDarkLaws = Refl

||| Verifies that Epoch 1 starts with 0 visible matter maxels (pre-baryogenesis vacuum state).
public export
0 verifyGenesisEmptyVisibleBaryons : (evalStateSpaceSaturation Epoch.ExpansionCollapse.initGenesisEpoch).occupiedMaxels = 0
verifyGenesisEmptyVisibleBaryons = Refl

||| Verifies that Genesis Epoch 1 total budget equals 128 (DE background).
public export
0 verifyGenesisVacuumTotal128 : (evalStateSpaceSaturation Epoch.ExpansionCollapse.initGenesisEpoch).totalOccupiedBudget = 128
verifyGenesisVacuumTotal128 = Refl

||| Audits that Epoch 37 reaches 100% capacity saturation matching derived observerEpoch37Budget.
public export
auditEpoch37FullSaturation : Bool
auditEpoch37FullSaturation = (evalStateSpaceSaturation getEpoch37State).totalOccupiedBudget == totalCapacity observerEpoch37Budget

public export
0 verifyEpoch37FullSaturation : Epoch.StateSpaceExhaustion.auditEpoch37FullSaturation = True
verifyEpoch37FullSaturation = Refl

--------------------------------------------------------------------------------
-- 3. ACTIVE INFERENCE HELMHOLTZ FREE ENERGY MINIMIZATION ENGINE (F = U - TS)
--------------------------------------------------------------------------------

||| Evaluates Helmholtz Free Energy F = U - TS of a cosmological epoch state.
||| Internal Energy U is total budget occupancy (VM + DE + DM).
||| Entropy S is total dark matter law residue (DM).
public export
evalFreeEnergy : EpochState -> Nat
evalFreeEnergy st =
  let ex = evalStateSpaceSaturation st
      u  = ex.totalOccupiedBudget
      s  = ex.accumulatedDarkLaws
  in minus u s

||| Audit verifying that cyclic Galois rebound (Epoch 37 -> 1) strictly minimizes Helmholtz free energy (F_vacuum = 128 <= F_epoch37 = 155).
public export
auditFreeEnergyMinimizationAtRebound : Bool
auditFreeEnergyMinimizationAtRebound =
  let st37 = MkEpochState 37 27 128 (AddM EllipticRed (intToBoxInt 55) ZeroM)
  in natLTE (evalFreeEnergy (reboundCyclicEpoch st37)) (evalFreeEnergy st37)

public export
0 verifyFreeEnergyMinimizationAtRebound : Epoch.StateSpaceExhaustion.auditFreeEnergyMinimizationAtRebound = True
verifyFreeEnergyMinimizationAtRebound = Refl
