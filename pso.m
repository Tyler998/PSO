%% �ú�����ʾ��Ŀ��perota�Ż�����
%��ջ���
clc
clear
dataset=xlsread('dataset.xlsx');
load data
%% ��ʼ����
%objnum=size(P,1); %������Ʒ����
%weight=92;        %����������

%��ʼ������
Dim=10;     %����ά��    ·����10���������
xSize=50;  %��Ⱥ����       
MaxIt=200; %��������
c1=0.8;    %�㷨����
c2=0.8;    %�㷨���� 
wmax=1.2;  %��������
wmin=0.1;  %��������

x=unidrnd(1000,xSize,Dim);  %���ӳ�ʼ��
v=zeros(xSize,Dim);      %�ٶȳ�ʼ��

xbest=x;           %�������ֵ
gbest=x(1,:);      %����Ⱥ���λ��

% ������Ӧ��ֵ 
cost=zeros(1,xSize);   %���ӳɱ�Ŀ��
time=zeros(1,xSize);   %����ʱ��Ŀ��
reliable=zeros(1,xSize);   %�ɿ���
ec=zeros(1,xSize);   %�ܺ�
% ����ֵ��ʼ��
cobest=zeros(1,xSize); %���ӳɱ�Ŀ��
tibest=zeros(1,xSize); %����ʱ��Ŀ��
rebest=zeros(1,xSize);  %�ɿ���
ecbest=zeros(1,xSize);  %�ܺ� ++++++++


% ��һ�ε�ֵ
coPrior=zeros(1,xSize);%���Ӽ�ֵĿ��
tiPrior=zeros(1,xSize);%�������Ŀ��
rePrior=zeros(1,xSize);%��¼����������Լ��
ecPrior=zeros(1,xSize);  %��¼����������Լ��+++++++

%�����ʼĿ������
for i=1:xSize
    for j=1:Dim %�������
        cost(i) = cost(i)+dataset(x(i,j),1);  %���ӳɱ�
        time(i) = time(i)+dataset(x(i,j),2);  %����ʱ��
        reliable(i) = reliable(i)+dataset(x(i,j),3);  %���ӿɿ���
        ec(i) = ec(i)+dataset(x(i,j),4);  %�����ܺ�+++++++
    end
end
% ��������λ��
cobest=cost;tibest=time;rebest=reliable;ecbest=ec;

%% ��ʼɸѡ���ӽ�
flj=[];
fljx=[];
fljNum=0;
%����ʵ����Ⱦ���
tol=1e-7;
for i=1:xSize
    flag=0;  %֧���־
    for j=1:xSize  
        if j~=i
            if ((cost(i)>cost(j)) &&  (time(i)>time(j)) && reliable(i)<reliable(i) && ec(i)>ec(i)) 
                flag=1;%��֧���־
                break;
            end
        end
    end
    
    %�ж����ޱ�֧��
    if flag==0
        fljNum=fljNum+1;
        % ��¼���ӽ�
        flj(fljNum,1)=cost(i);flj(fljNum,2)=time(i);flj(fljNum,3)=reliable(i);flj(fljNum,4)=ec(i);
        % ���ӽ�λ��
        fljx(fljNum,:)=x(i,:); 
    end
end

%% ѭ������
for iter=1:MaxIt
    
    % Ȩֵ����
    w=wmax-(wmax-wmin)*iter/MaxIt;
     
    %�ӷ��ӽ���ѡ��������Ϊȫ�����Ž�
    s=size(fljx,1);       
    index=randi(s,1,1);  
    gbest=fljx(index,:);

    %% Ⱥ�����
    for i=1:xSize
        %�ٶȸ���
        v(i,:)=w*v(i,:)+c1*rand(1,1)*(xbest(i,:)-x(i,:))+c2*rand(1,1)*(gbest-x(i,:));
        
        %λ�ø���
        x(i,:)=x(i,:)+v(i,:);  
        index1=find(x(i,:)<=0);
        if ~isempty(index1)
            x(i,index1)=rand(size(index1));
        end
        for j=1:10
            if x(i,j)>1000
                x(i,j)=1000;
            end
            
        x(i,:)=ceil(x(i,:));        
        end
    end
    
    %% ���������Ӧ��
    coPrior(:)=0;
    tiPrior(:)=0;
    rePrior(:)=0;
    ecPrior(:)=0;
    for i=1:xSize
        for j=1:Dim %�������
            coPrior(i) = coPrior(i)+dataset(x(i,j),1);  %�������ӳɱ�
            tiPrior(i) = tiPrior(i)+dataset(x(i,j),2);  %��������ʱ��
            rePrior(i) = rePrior(i)+dataset(x(i,j),3);  %�������ӿɿ���
            ecPrior(i) = ecPrior(i)+dataset(x(i,j),4);  %���������ܺ�
        end
    end
    
    %% ����������ʷ���
    for i=1:xSize
        for j=1:xSize
        %���ڵ�֧��ԭ�еģ����ԭ�е�
         if ((cost(i)<cost(j)) &&  (time(i)<time(j)) && reliable(i)>reliable(j) && ec(i)<ec(j))
                xbest(i,:)=x(i,:);%û�м�¼Ŀ��ֵ
                cobest(i)=coPrior(i);tibest(i)=tiPrior(i);rebest(i)=rePrior(i);ecbest(i)=ecPrior(i);
        elseif rand(1,1)<0.5
                xbest(i,:)=x(i,:);
                  cobest(i)=coPrior(i);tibest(i)=tiPrior(i);rebest(i)=rePrior(i);ecbest(i)=ecPrior(i);
         end
        end
    end

    %% ���·��ӽ⼯��
    cost=coPrior;
    time=tiPrior;
    reliable=rePrior;
    ecliable=ecPrior;
    %�����������ӽ⼯��
    s=size(flj,1);%Ŀǰ���ӽ⼯����Ԫ�ظ���
   
    %�Ƚ����ӽ⼯�Ϻ�xbest�ϲ�
    cccx=zeros(1,s+xSize);
    tttx=zeros(1,s+xSize);
    rrrx=zeros(1,s+xSize);
    eeex=zeros(1,s+xSize);
    
    cccx(1:xSize)=cobest;cccx(xSize+1:end)=flj(:,1)';
    tttx(1:xSize)=tibest;tttx(xSize+1:end)=flj(:,2)';
    rrrx(1:xSize)=rebest;rrrx(xSize+1:end)=flj(:,3)';
    eeex(1:xSize)=ecbest;eeex(xSize+1:end)=flj(:,4)';
    
    xxbest=zeros(s+xSize,Dim);
    xxbest(1:xSize,:)=xbest;
    xxbest(xSize+1:end,:)=fljx;
   
    %ɸѡ���ӽ�
    flj=[];
    fljx=[];
    k=0;
    tol=1e-7;
    for i=1:xSize+s
        flag=0;%û�б�֧��
        %�жϸõ��Ƿ����
        for j=1:xSize+s 
            if j~=i
                if ((cccx(i)>cccx(j)) &&  (tttx(i)>tttx(j)) &&  (rrrx(i)<rrrx(j)) && (eeex(i)<eeex(j)))  %��һ�α�֧��
                    flag=1;
                    break;
                end
            end
        end

        %�ж����ޱ�֧��
        if flag==0
            k=k+1;
            flj(k,1)=cccx(i);flj(k,2)=tttx(i);flj(k,3)=rrrx(i);flj(k,4)=eeex(i);%��¼���ӽ�
            fljx(k,:)=xxbest(i,:);%���ӽ�λ��
        end
    end
    
    %ȥ���ظ�����
    repflag=0;   %�ظ���־
    k=1;         %��ͬ���ӽ�������
    flj2=[];     %�洢��ͬ���ӽ�
    fljx2=[];    %�洢��ͬ���ӽ�����λ��
    flj2(k,:)=flj(1,:);
    fljx2(k,:)=fljx(1,:);
    for j=2:size(flj,1)
        repflag=0;  %�ظ���־
        for i=1:size(flj2,1)
            result=(fljx(j,:)==fljx2(i,:));
            if length(find(result==1))==Dim
                repflag=1;%���ظ�
            end
        end
        %���Ӳ�ͬ���洢
        if repflag==0 
            k=k+1;
            flj2(k,:)=flj(j,:);
            fljx2(k,:)=fljx(j,:);
        end
        
    end
    
    %���ӽ����
    flj=flj2;
    fljx=fljx2;
 disp(['In iteration ' num2str(iter) ]);
    save results
end
