function [label_Bin,num_label] = labelBinary(labelMap)
%LABELBINARY ��������ǩת���ɶ�������ʽ
%   �˴���ʾ��ϸ˵��
maplen = 6;
[~,col] = size(labelMap); %����Map_origin_I������ֵ
label_Bin = zeros();
t = 0; %����������������ĳ���

for i=1:col
    label_Bin(t+1:t+maplen) = dec2bin(labelMap(i),maplen)-'0';
    t = t + maplen;
end 
[~,num_label] = size(label_Bin);
