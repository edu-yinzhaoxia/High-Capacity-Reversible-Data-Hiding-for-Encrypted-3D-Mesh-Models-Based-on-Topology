function [label_map,vertemb] = markEmbbed(vertex0, face, bit_len,HP)
%MARKEMBBED ������¼ÿ��Ƕ�뼯�����Ƕ�����ݵĳ���
%% Separate Vertexes into 2 Sets
[num_face, ~] = size(face);
[num_vert,~] =size(vertex0);
face = int32(face);
%% ty�޸ĺ��
%% ��ȡface��Ƶ������ ��������
Vertemb = int32([]);
Vertnoemb = int32([]);
s_info = repmat(struct('id',[],'num',[],'ref',[],'status',[]),num_vert,1);
%% Ϊÿ������Ѱ��ص� ��ȥ����Ƶ������
i = 1;
while i <= num_vert
    s_info(i).id =i ;
    location = mod(find(i==face),num_face);% �ҵ������face�г��ֵ���������
    location(location==0) = num_face; %  ������Ϊmod���������0ֵ
    [num_location,~] = size(location);
    for m = 1:num_location
        one = face(location(m),1);
        two = face(location(m),2);
        three = face(location(m),3);
        v1 = isempty(find(one==i))==0;
        v2 = isempty(find(two==i))==0; 
        v3 = isempty(find(three==i))==0;
        if(v1==1)
            Vertnoemb = [Vertnoemb two, three];
        elseif(v2==1)
            Vertnoemb = [Vertnoemb one, three];
        elseif(v3==1)
            Vertnoemb = [Vertnoemb one, two];
        end
    end
    Vertnoemb = unique(Vertnoemb);
    [~,num] = size(Vertnoemb);
    s_info(i).ref = Vertnoemb;
    s_info(i).num = num;
    s_info(i).status= 0;
    Vertnoemb = [];
    i = i+1;
end
% �����µ���������Ϣ  ɸѡ���������ż��������(ż�����������������)��������������Ϊ���ӣ�
[~,ind]=sort([s_info.id],'ascend');
new_info=s_info(ind);
Vertemb_even = int32([]);  % ѡ��һЩ���ʺ�Ƕ���ż����

for j = 1:num_vert
    if (mod((new_info(j).id),2)==0)% ����ǰ�ڵ���Ԥ�⼯��ż����   
        % �ж�����Χ��������Ŀ�ǲ��Ƕ���ż���� ����� ���ż��������Ԥ����� ��֮����Ƕ�� ��Ϊż����� Ԥ�����
        even = find(mod(new_info(j).ref,2)==0);% ��Χ��ż������Ŀ
        temp = setdiff(new_info(j).ref(even),Vertemb_even);
        even = temp;
        odd = find(mod(new_info(j).ref,2)==1); % ��Χ����������Ŀ
        if(((length(odd)<2*length(even))&&(length(even)>=1)))
%         if((length(even)>=(HP+length(odd)))&&(length(even)>2))
            Vertemb_even = [Vertemb_even new_info(j).id];
        end
    end
end

for k = 1:num_vert
    if (mod((new_info(k).id),2)~=0)% ����ǰ�ڵ�����������
        Vertemb = [Vertemb new_info(k).id];
        mid = find(mod(new_info(k).ref,2)==0);
        new_info(k).ref = new_info(k).ref(mid);
        new_info(k).ref = setdiff(new_info(k).ref(:),Vertemb_even(:));% ȥ������Ƕ����Ԥ�⼯��ż��Ƕ���Ķ���
    elseif (sum(ismember(Vertemb_even, new_info(k).id)))
        Vertemb = [Vertemb new_info(k).id];
        mid = find(mod(new_info(k).ref,2)==0);
        new_info(k).ref = new_info(k).ref(mid);
        new_info(k).ref = setdiff(new_info(k).ref(:),Vertemb_even(:));
    end
end
vertemb = Vertemb;

%% Calculate and record prediction error
[~,count]= size(Vertemb);
label_map = [];
for v = 1:count
    refer_vex = [];
    refer_vex = new_info(Vertemb(v)).ref;
    refer_vex = unique(refer_vex);
    refer_vex = setdiff(refer_vex(:),Vertemb(:))';
    [~,refer_num] = size(refer_vex);
    if refer_num>0  % ����������������껯Ϊ�����Ʊ�ʾ
        bin1 = int32(dec2binPN( vertex0(Vertemb(v),1), bit_len)');
        bin2 = int32(dec2binPN( vertex0(Vertemb(v),2), bit_len)');
        bin3 = int32(dec2binPN( vertex0(Vertemb(v),3), bit_len)');
        % �������������ص����ͳ��
        refer_bin1 = int32(zeros(1, bit_len));
        refer_bin2 = int32(zeros(1, bit_len));
        refer_bin3 = int32(zeros(1, bit_len));
        for j = 1:refer_num
            refer_bin1 = refer_bin1 + int32(dec2binPN( vertex0(refer_vex(j),1), bit_len)');
            refer_bin2 = refer_bin2 + int32(dec2binPN( vertex0(refer_vex(j),2), bit_len)');
            refer_bin3 = refer_bin3 + int32(dec2binPN( vertex0(refer_vex(j),3), bit_len)');
        end
        % �����е�Ԥ�������������� �ٳ���Ԥ�����Ŀ ���Ԥ��ֵ
        refer_bin1 = int32(refer_bin1/refer_num);
        refer_bin2 = int32(refer_bin2/refer_num);
        refer_bin3 = int32(refer_bin3/refer_num);
        % tֵΪԤ��׼ȷ�Ķ����Ƹ���
        t1=0;   
        t2=0;
        t3=0;
        % ͨ������forѭ�� ��ȡԤ�����Ƕ����Ԥ��׼ȷ��
        for k1 = 1:bit_len
            if bin1(k1) == refer_bin1(k1)
                t1 = k1;
            else
                break;
            end
        end
        for k2 = 1:bit_len
            if bin2(k2) == refer_bin2(k2)
                t2 = k2;
            else
                break;
            end
        end
        for k3 = 1:bit_len
            if bin3(k3) == refer_bin3(k3)
                t3 = k3;
            else
                break;
            end
        end
        t0 = [t1 t2 t3];
        t = min(t0);
        label_map = [label_map t];
    else
        label_map = [label_map 0];
        continue;
    end
end
end
