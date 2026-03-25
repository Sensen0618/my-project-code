clc; clear;

% Set graphics display parameters
set(0, 'DefaultAxesFontSize', 10);
set(0, 'DefaultTextFontSize', 12);

time = [65.852906, 154.288860, 150.386522, 60.297269];

% Load the first file and rename the record variable to record1
data1 = load('case2_PSO1_record.mat');
record1 = data1.record;  % If the original program saved as record, use data1.record here

data2 = load('case2_PSO2_record.mat');
record2 = data2.record;

data3 = load('case2_PSO3_record.mat');
record3 = data3.record;

data4 = load('case2_PSO4_record.mat');
record4 = data4.record;

% % Find the maximum length for unifying the x-axis
% max_len = max([length(record1), length(record2), length(record3), length(record4)]);
% 
% % Create figure
% figure('Position', [100, 100, 1200, 800]);
% 
% % (a) k=1 
% subplot(2, 2, 1);
% plot(record1, 'b-', 'LineWidth', 2);
% xlabel('Iterations', 'FontSize', 16);
% ylabel('Optimal Total Power', 'FontSize', 16);
% title('(a) k=1', 'FontSize', 16, 'FontWeight', 'bold');
% grid on;
% 
% % Add annotation for final value
% final_value1 = record1(end);
% text(length(record1)*0.45, max(record1)*0.8, sprintf('Final Power: %.2e', final_value1), ...
%     'FontSize', 16, 'BackgroundColor', 'white');
% text(length(record1)*0.45, max(record1)*0.65, sprintf('runtime: %.2f S', time(1)), ...
%     'FontSize', 16, 'BackgroundColor', 'white');
% 
% % (b) k=2 
% subplot(2, 2, 2);
% plot(record2, 'r-', 'LineWidth', 2);
% xlabel('Iterations', 'FontSize', 16);
% ylabel('Optimal Total Power', 'FontSize', 16);
% title('(b) k=2', 'FontSize', 16, 'FontWeight', 'bold');
% grid on;
% 
% % Add annotation for final value
% final_value2 = record2(end);
% text(length(record2)*0.5, max(record2)*0.8, sprintf('Final Power: %.2e', final_value2), ...
%     'FontSize', 16, 'BackgroundColor', 'white');
% text(length(record2)*0.5, max(record2)*0.65, sprintf('runtime: %.2f S', time(2)), ...
%     'FontSize', 16, 'BackgroundColor', 'white');
% 
% % (c) k=3 
% subplot(2, 2, 3);
% plot(record3, 'g-', 'LineWidth', 2);
% xlabel('Iterations', 'FontSize', 16);
% ylabel('Optimal Total Power', 'FontSize', 16);
% title('(c) k=3', 'FontSize', 16, 'FontWeight', 'bold');
% grid on;
% 
% % Add annotation for final value
% final_value3 = record3(end);
% text(length(record3)*0.45, max(record3)*0.8, sprintf('Final Power: %.2e', final_value3), ...
%     'FontSize', 16, 'BackgroundColor', 'white');
% text(length(record3)*0.45, max(record3)*0.65, sprintf('runtime: %.2f S', time(3)), ...
%     'FontSize', 16, 'BackgroundColor', 'white');
% 
% % (d) k=4 
% subplot(2, 2, 4);
% plot(record4, 'm-', 'LineWidth', 2);
% xlabel('Iterations', 'FontSize', 16);
% ylabel('Optimal Total Power', 'FontSize', 16);
% title('(d) k=4', 'FontSize', 16, 'FontWeight', 'bold');
% grid on;
% 
% % Add annotation for final value
% final_value4 = record4(end);
% text(length(record4)*0.45, max(record4)*0.8, sprintf('Final Power: %.2e', final_value4), ...
%     'FontSize', 16, 'BackgroundColor', 'white');
% text(length(record4)*0.45, max(record4)*0.65, sprintf('runtime: %.2f S', time(4)), ...
%     'FontSize', 16, 'BackgroundColor', 'white');
% 
% % Add overall title
% % sgtitle('Comparison of PSO Optimization Performance under Different Fusion Rules', 'FontSize', 14, 'FontWeight', 'bold');
% 
% % Adjust subplot spacing
% h = gcf;
% set(h, 'PaperPositionMode', 'auto');

figure;
plot(1:length(record1), record1, 'b-', 'LineWidth', 1.5, 'DisplayName', 'k=1');
hold on;
plot(1:length(record2), record2, 'r--', 'LineWidth', 1.5, 'DisplayName', 'k=2');
plot(1:length(record3), record3, 'g-.', 'LineWidth', 1.5, 'DisplayName', 'k=3');
plot(1:length(record4), record4, 'm:', 'LineWidth', 1.5, 'DisplayName', 'k=4');
hold off;

xlabel('Iterations', 'FontSize', 14);
ylabel('Optimal Total Power', 'FontSize', 14);
legend('show');
grid on;

% Save figure
print('case2_PSO1234.jpg', '-dpng', '-r300');
fprintf('Figure saved as case2_PSO1234.jpg\n');