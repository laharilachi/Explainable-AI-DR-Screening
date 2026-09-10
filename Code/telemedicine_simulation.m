%% SIH26038 - Telemedicine Workflow Simulation
clc; clear; close all;

% Parameters
patients_per_day = 50;          % Images coming from PHC
doctor_capacity  = 40;          % Cases doctor can review per day
days = 1:30;                    % Simulation for 30 days

% Backlog calculation
backlog = zeros(size(days));
current_backlog = 0;

for i = 1:length(days)
    current_backlog = current_backlog + patients_per_day - doctor_capacity;
    current_backlog = max(0, current_backlog);   % backlog cannot be negative
    backlog(i) = current_backlog;
end

% Plot
figure('Name','Telemedicine Simulation','Position',[100 100 900 500]);
plot(days, backlog, 'b-o', 'LineWidth', 2);
grid on;
xlabel('Days');
ylabel('Pending Cases (Backlog)');
title('Rural DR Screening - Telemedicine Backlog Simulation');
legend(['Patients/day = ' num2str(patients_per_day) ' | Doctor capacity = ' num2str(doctor_capacity)]);

% Display result
if backlog(end) == 0
    fprintf('Result: System is stable. No backlog.\n');
else
    fprintf('Result: Backlog is increasing. More doctors or capacity needed.\n');
end