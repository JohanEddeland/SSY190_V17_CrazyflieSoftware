%% Breach script for closed_loop.slx

%% Initialize Breach
InitBreach;
B = BreachSimulinkSystem('closed_loop');

% We can print the signals of the system
B.PrintSignals();

% We can also find specifically just the inputs of the system
inputs = B.Sys.InputList;
disp('Inputs:');
disp(inputs);

%% Create input generators
% We create input generators for all inputs of the system
% As we saw in the 'inputs' list, the input of the system are:
% - Roll_reference
% - Pitch_reference
% - Yaw_reference
% - Yawrate_reference

% You have 4 different input generators at your disposal:
% - pulse_signal_gen generates pulse signals. You can set the base value,
%   period, pulse width, amplitude and delay

% Pitch reference input generator: choose one by commenting/uncommenting!
thrust_gen    = pulse_signal_gen({'Base_Thrust'});
% thrust_gen    = fixed_cp_signal_gen({'Base_Thrust'},... % Signal name
%                                     3); % Number of control points
% thrust_gen    = var_cp_signal_gen({'Base_Thrust'},... % Signal name
%                                     3); % Number of control points
% thrust_gen    = var_step_signal_gen({'Base_Thrust'},... % Signal name
%                                     3); % Number of control points

% Roll reference input generator: choose one by commenting/uncommenting!
% roll_gen    = pulse_signal_gen({'Ref_Roll'});
roll_gen    = fixed_cp_signal_gen({'Ref_Roll'}, ... % Signal name
                                     3); % Number of control points
% roll_gen    = var_cp_signal_gen({'Ref_Roll'},... % Signal name
%                                     3); % Number of control points
% roll_gen    = var_step_signal_gen({'Ref_Roll'},...
%                                     3); % Number of control points

% Pitch reference input generator: choose one by commenting/uncommenting!
% pitch_gen    = pulse_signal_gen({'Ref_Pitch'});
% pitch_gen    = fixed_cp_signal_gen({'Ref_Pitch'},... % Signal name
%                                     3); % Number of control points
pitch_gen    = var_cp_signal_gen({'Ref_Pitch'},... % Signal name
                                    3); % Number of control points
% pitch_gen    = var_step_signal_gen({'Pitch_reference'},... % Signal name
%                                     3); % Number of control points

% Pitch reference input generator: choose one by commenting/uncommenting!
% yawrate_gen    = pulse_signal_gen({'Ref_YawRate'});
% yawrate_gen    = fixed_cp_signal_gen({'Ref_YawRate'},... % Signal name
%                                     3); % Number of control points
% yawrate_gen    = var_cp_signal_gen({'Ref_YawRate'},... % Signal name
%                                     3); % Number of control points
yawrate_gen    = var_step_signal_gen({'Ref_YawRate'},... % Signal name
                                    3); % Number of control points



% We have to combine all the different generators into a Breach generator
% system
InputGen = BreachSignalGen({thrust_gen, roll_gen, pitch_gen, yawrate_gen});

% We tell Breach that InputGen is the generator to use for our system
B.SetInputGen(InputGen);

% We can print all the parameters of the system after creating the input
% generators
B.PrintParams();

%% Set input generator parameters

% The input parameters get standard values assigned to them
% We can change them manually in the following way:
B.SetParam({'Base_Thrust_base_value','Base_Thrust_pulse_amp','Base_Thrust_pulse_period'},...
                        [1 20000 4]);
B.SetParam({'Ref_Roll_u0', 'Ref_Roll_u1', 'Ref_Roll_u2'},...
                        [1 0 2]);
B.SetParam({'Ref_Pitch_dt0', 'Ref_Pitch_dt1'},...
                        [2 5]);               
                    
% For some input parameters we might want to assign a RANGE of values. 
% This is done in the following way:
%B.SetParamRanges({'Ref_Pitch_u0', 'Ref_Pitch_u1', 'Ref_Pitch_u2'},...
%                        [-1 1; -1 1; -1 1]);
                    
%% Sample parameters
% For all parameters that have a range defined, we can sample parameter
% values in the following way:
B.QuasiRandomSample(3); % Samples 3 values

%% Simulate the system
TotalSimulationTime = 10;
B.SetTime(TotalSimulationTime); % Set the total simulation time to e.g. 10s
B.Sim(); % Simulate the system

%% Plot results
% We can plot each signal against its reference for the first scenario ...
B.PlotSignals({'Base_Thrust'},...% Signals to plot
	[1],... % Which scenario to plot (only the first)
	{},... % Additional options
	1); % Boolean indicating that signals should be plotted in ONE figure 

B.PlotSignals({'Roll_reference','Roll'},... % Signals to plot
	[1],... % Which scenario to plot (only the first)
	{},... % Additional options
	1); % Boolean indicating that signals should be plotted in ONE figure

B.PlotSignals({'Pitch_reference','Pitch'},...% Signals to plot
	[1],... % Which scenario to plot (only the first)
	{},... % Additional options
	1); % Boolean indicating that signals should be plotted in ONE figure

B.PlotSignals({'Yaw_reference','Yaw'},...% Signals to plot
	[1],... % Which scenario to plot (only the first)
	{},... % Additional options
	1); % Boolean indicating that signals should be plotted in ONE figure      


            
% ... and we can also plot ALL signals in ALL scenarios in ONE figure
B.PlotSignals({'Roll_reference','Roll','Pitch_reference','Pitch','Yaw_reference','Yaw'});
B.PlotSignals({'Base_Thrust','x','y','z'});
            

%% Write specifications for the system
% Now we want to really test the system to see if it fulfills
% specifications

% To see which signals the system has, use the following:
B.PrintSignals();
% The signals we can use in our STL formulae are:
% - Pitch[t]
% - Roll[t]
% - Yaw[t]
% - Roll_reference[t]
% - Pitch_reference[t]
% - Yaw_reference[t]
% - Yawrate_reference[t]

% We want to see if the yaw is always close to its reference or not
% The STL specification for this could be:
yaw_close_to_ref = STL_Formula('yaw_close_to_ref','alw_[0,TotalSimulationTime](abs(Yaw[t] - Yaw_reference[t]) < tol)');
% What should the tolerance be? Let's try with 0.1
yaw_close_to_ref = set_params(yaw_close_to_ref,{'tol'},[0.1]);

% Check the specification against the simulations we performed
yaw_results = B.CheckSpec(yaw_close_to_ref);
disp('Spec satisfaction results:')
disp(yaw_results);

% Negative results mean that the robustness is negative, i.e., the
%   specification is not fulfilled. 
% We can plot the robustness function of the specification for a more
%   detailed view.
B.PlotRobustSat(yaw_close_to_ref,... % Specification to plot
    inf,... % Depth of formula to plot
    [],... % Time instants where to evaluate
    1);

% Ok, so the tolerance of 0.1 was probably too tight ... how about 0.8?
yaw_close_to_ref2 = set_params(yaw_close_to_ref,{'tol'},[0.8]);

% Check specification again
yaw_results2 = B.CheckSpec(yaw_close_to_ref2);
disp('Spec satisfaction results, second try:')
disp(yaw_results2);

% Positive results mean that the specification is fulfilled for all three
%   scenarios!
% To verify the results, we can plot robustness for scenario 1 again:
B.PlotRobustSat(yaw_close_to_ref2,... % Specification to plot
    inf,... % Depth of formula to plot
    [],... % Time instants where to evaluate
    1);

%% Falsification
% So the specification holds for the given three scenarios. But will it
%   hold for all different scenarios?
% To tackle this question, we use FALSIFICATION. 

% First, we create a Breach falsification problem
falsif_pb = FalsificationProblem(B, yaw_close_to_ref2);
% Now, we let Breach attempt to solve it!
res = falsif_pb.solve();
                    
if ~isempty(res)
    % Breach managed to falsify the specification
    B_False = falsif_pb.GetBrSet_False();
    % B_False is the same as B, but containing the falsified trajectory
    
    % Plot the robustness to visualize why the specification was not held
    B_False.PlotRobustSat(yaw_close_to_ref2);
end


%% Parameter synthesis
% We falsified the property that yaw stays within tol=0.1 of its reference.
% We might also ask: for what minimum value of tol is this property true?
% To answer this, we use parameter synthesis

% Create a parameter synthesis problem
synth_pb = ParamSynthProblem(B, yaw_close_to_ref2, {'tol'},  [0 1]);

% Let Breach solve it
synth_pb.solve();

% Store the best (=lowest) possible tolerance for which the specification
%   holds. 
tol_best  = synth_pb.x_best;
