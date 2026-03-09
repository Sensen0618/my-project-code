clc; clear;

% 设置图形显示参数
set(0, 'DefaultAxesFontSize', 10);
set(0, 'DefaultTextFontSize', 12);

time = [281.383074, 1005.133156, 316.551715, 423.504468];

% 加载数据
load('GA1_record.mat', 'record1');
load('GA2_record.mat', 'record2');
load('GA3_record.mat', 'record3');
load('GA4_record.mat', 'record4');

% % 找到最大长度，用于统一x轴
% max_len = max([length(record1), length(record2), length(record3), length(record4)]);
% 
% % 创建图形
% figure('Position', [100, 100, 1200, 800]);
% 
% % (a) k=1 遗传算法收敛曲线
% subplot(2, 2, 1);
% plot(record1, 'b-', 'LineWidth', 2);
% xlabel('Iterations', 'FontSize', 16);
% ylabel('Optimal Total Power', 'FontSize', 16);
% title('(a) k=1', 'FontSize', 16, 'FontWeight', 'bold');
% grid on;
% 
% % 添加收敛值标注
% final_value1 = record1(end);
% text(length(record1)*0.5, max(record1)*0.8, sprintf('Final Power: %.2e', final_value1), ...
%     'FontSize', 16, 'BackgroundColor', 'white');
% text(length(record1)*0.5, max(record1)*0.65, sprintf('runtime: %.2f S', time(1)), ...
%     'FontSize', 16, 'BackgroundColor', 'white');
% 
% % (b) k=2 遗传算法收敛曲线
% subplot(2, 2, 2);
% plot(record2, 'r-', 'LineWidth', 2);
% xlabel('Iterations', 'FontSize', 16);
% ylabel('Optimal Total Power', 'FontSize', 16);
% title('(b) k=2', 'FontSize', 16, 'FontWeight', 'bold');
% grid on;
% 
% % 添加收敛值标注
% final_value2 = record2(end);
% text(length(record2)*0.45, max(record2)*0.8, sprintf('Final Power: %.2e', final_value2), ...
%     'FontSize', 16, 'BackgroundColor', 'white');
% text(length(record2)*0.45, max(record2)*0.65, sprintf('runtime: %.2f S', time(2)), ...
%     'FontSize', 16, 'BackgroundColor', 'white');
% 
% % (c) k=3 遗传算法收敛曲线
% subplot(2, 2, 3);
% plot(record3, 'g-', 'LineWidth', 2);
% xlabel('Iterations', 'FontSize', 16);
% ylabel('Optimal Total Power', 'FontSize', 16);
% title('(c) k=3', 'FontSize', 16, 'FontWeight', 'bold');
% grid on;
% 
% % 添加收敛值标注
% final_value3 = record3(end);
% text(length(record3)*0.45, max(record3)*0.8, sprintf('Final Power: %.2e', final_value3), ...
%     'FontSize', 16, 'BackgroundColor', 'white');
% text(length(record3)*0.45, max(record3)*0.65, sprintf('runtime: %.2f S', time(3)), ...
%     'FontSize', 16, 'BackgroundColor', 'white');
% 
% % (d) k=4 遗传算法收敛曲线
% subplot(2, 2, 4);
% plot(record4, 'm-', 'LineWidth', 2);
% xlabel('Iterations', 'FontSize', 16);
% ylabel('Optimal Total Power', 'FontSize', 16);
% title('(d) k=4', 'FontSize', 16, 'FontWeight', 'bold');
% grid on;
% 
% % 添加收敛值标注
% final_value4 = record4(end);
% text(length(record4)*0.5, max(record4)*0.8, sprintf('Final Power: %.2e', final_value4), ...
%     'FontSize', 16, 'BackgroundColor', 'white');
% text(length(record4)*0.5, max(record4)*0.65, sprintf('runtime: %.2f S', time(4)), ...
%     'FontSize', 16, 'BackgroundColor', 'white');
% 
% % 添加总标题
% % sgtitle('遗传算法在不同融合规则下的优化性能对比', 'FontSize', 14, 'FontWeight', 'bold');
% 
% % 调整子图间距
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

% 保存图形
print('GA1234.jpg', '-dpng', '-r300');
fprintf('图形已保存为 GA1234.jpg\n');