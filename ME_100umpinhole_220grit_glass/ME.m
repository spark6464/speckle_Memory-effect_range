%% % 读取中心参考图像
ref_img = im2double(imread('0.bmp'));

% 初始化存储互相关系数的数组
num_images = 40;
corr_coeffs = zeros(num_images + 1, 1);
corr_coeffs(21) = 1; % 0.bmp 的自相关系数设为 1

% 生成横坐标 (单位: mm)，从 -1 mm 到 1 mm，步长为 0.05 mm
x_axis = (-20:20) * 0.05;

index = 1;
for i = -20:20
    % 处理中心图像 0.bmp，直接赋值为 1
    if i == 0
        fprintf('Position %.2f mm: Cross-Correlation = 1.000000\n', x_axis(index));
        index = index + 1;
        continue;
    end
    
    % 读取当前散斑图像
    img_name = sprintf('%d.bmp', i);
    curr_img = im2double(imread(img_name));
    
    % 计算互相关系数
    corr_matrix = normxcorr2(ref_img, curr_img);
    max_corr = max(corr_matrix(:)); % 取最大互相关值
    
    % 存储结果
    corr_coeffs(index) = max_corr;
    
    % 输出结果
    fprintf('Position %.2f mm: Cross-Correlation = %.6f\n', x_axis(index), max_corr);
    
    index = index + 1;
end


%% 绘制互相关系数
figure;
scatter(x_axis, corr_coeffs, 50, 'o', 'filled', 'LineWidth', 2); % 实心黑色圆点
hold on;

% 设置 y 轴范围
xlim([-1.1 1.1]);
ylim([0 1.1]);

% 设置坐标轴刻度字体大小
set(gca, 'FontSize', 18);

% 设置横纵坐标标签
xlabel('x (mm)', 'FontSize', 18);
ylabel('Correlation Coefficient', 'FontSize', 18);
% 打开坐标轴的边框
box on;


%%  计算互相关系数并进行高斯拟合
gaussEqn = 'A*exp(-((x-mu)^2)/(2*sigma^2)) + B';
fit_params = fit(x_axis(:), corr_coeffs(:), gaussEqn, 'StartPoint', [1, 0, 0.01, 0.1]);

% 生成拟合曲线
x_fit = linspace(min(x_axis), max(x_axis), 100);
y_fit = fit_params.A * exp(-((x_fit - fit_params.mu).^2) / (2 * fit_params.sigma^2)) + fit_params.B;

% 绘制互相关系数和拟合曲线
figure;
scatter(x_axis, corr_coeffs, 50, 'o', 'filled', 'LineWidth', 2); % 实心黑色圆点
hold on;
plot(x_fit, y_fit, 'r-', 'LineWidth', 2); % 绘制红色高斯拟合曲线

% 设置 y 轴范围
xlim([-1.1 1.1]);
ylim([0 1.1]);

% 设置坐标轴刻度字体大小
set(gca, 'FontName', 'Times New Roman', 'FontSize', 20);

% 设置横纵坐标标签
xlabel('x (mm)', 'FontSize', 20);
ylabel('Correlation Coefficient',  'FontSize', 20);

% 打开坐标轴的边框
box on;

% 显示拟合参数
disp(['A = ', num2str(fit_params.A)]);
disp(['mu = ', num2str(fit_params.mu)]);
disp(['sigma = ', num2str(fit_params.sigma)]);
disp(['B = ', num2str(fit_params.B)]);

% 添加图例
legend('Data Points', 'Gaussian Fit', 'Location', 'best');
set(legend, 'FontSize', 18);  % 设置图例字体大小为 14

