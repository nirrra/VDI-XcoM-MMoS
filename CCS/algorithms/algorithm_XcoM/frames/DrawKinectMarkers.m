%% 显示T-pose下的所有标记点
function [] = DrawKinectMarkers(stream,frame)
names = fieldnames(stream); names = names(4:35);
idxMarkers = [1:6,12,13,19:27];
f = figure(1); 
% set(f, 'Color', [0.85,0.85,0.85]); % 设置为白色背景，可以根据需要更改RGB值
set(f, 'Color', [1, 1, 1]); % 设置为白色背景，可以根据需要更改RGB值

scatter3(stream.(names{1}).x(frame),stream.(names{1}).y(frame),stream.(names{1}).z(frame),60,'MarkerEdgeColor','k','MarkerFaceColor',[190,46,56]./255); hold on;
for i = 2:size(names,1)
    if ismember(i,idxMarkers)
        scatter3(stream.(names{i}).x(frame),stream.(names{i}).y(frame),stream.(names{i}).z(frame),60,'MarkerEdgeColor','k','MarkerFaceColor',[190,46,56]./255); 
    else
%         scatter3(stream.(names{i}).x(frame),stream.(names{i}).y(frame),stream.(names{i}).z(frame),60,'MarkerEdgeColor','k','MarkerFaceColor',[0,200,200]./255); 
    end
end
hold off;
axis equal;
xlim([-0.9,0.9]);
axis off;
% grid off;
view(-5,15);
% exportgraphics(f,'Kinect markers.png','Resolution',600);

% set(gcf, 'InvertHardCopy', 'off');
print(f, 'Kinect markers.png', '-dpng', '-r600', '-painters');
