/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * File: crazyflie.c
 *
 * Code generated for Simulink model 'crazyflie'.
 *
 * Model version                  : 1.163
 * Simulink Coder version         : 8.11 (R2016b) 25-Aug-2016
 * C/C++ source code generated on : Wed Mar 22 11:34:50 2017
 *
 * Target selection: ert.tlc
 * Embedded hardware selection: ARM Compatible->ARM Cortex
 * Code generation objectives:
 *    1. Execution efficiency
 *    2. RAM efficiency
 * Validation result: Not run
 */

#include "crazyflie.h"

/* Block signals and states (auto storage) */
DW rtDW;

/* External inputs (root inport signals with auto storage) */
ExtU rtU;

/* External outputs (root outports fed by signals with auto storage) */
ExtY rtY;

/* Model step function */
void crazyflie_step(void)
{
  /* Outport: '<Root>/Log1' incorporates:
   *  DiscreteIntegrator: '<Root>/Discrete-Time Integrator'
   */
  rtY.Log1 = rtDW.DiscreteTimeIntegrator_DSTATE;

  /* Update for DiscreteIntegrator: '<Root>/Discrete-Time Integrator' incorporates:
   *  Update for Inport: '<Root>/Gyro_x'
   */
  rtDW.DiscreteTimeIntegrator_DSTATE += 0.01 * rtU.Gyro_x;
}

/* Model initialize function */
void crazyflie_initialize(void)
{
  /* (no initialization code required) */
}

/* Model terminate function */
void crazyflie_terminate(void)
{
  /* (no terminate code required) */
}

/*
 * File trailer for generated code.
 *
 * [EOF]
 */
