%%%%% Plot IRFs

if VAR.singleVAR == true
    Fig.numFigs = VAR.numVars;
    
    if VAR.doCholVAR == true
        Fig.cholIRFs = CholVAR.IRFs;
    end
    
    Fig.ivIRFs = SVARIV.IRFs(:,VAR.cholOrder);
    Fig.ivIRFsL = SVARIV.IRFsL(:,:,VAR.cholOrder);
    Fig.ivIRFsH = SVARIV.IRFsH(:,:,VAR.cholOrder);
    
    Fig.labels1 = VAR.varsLbls(VAR.cholOrder);
    Fig.subLbls1 = SVARIV.rfAdjR2(VAR.cholOrder);
    Fig.subLbls2 = SVARIV.fsFstat;
    Fig.subLbls3 = SVARIV.fsHetRobFstat;
else
    Fig.numFigs = VAR.iterate;
    
    if VAR.doCholVAR == true
        Fig.cholIRFs = VAR.cholLaborVar2IRFs;
    end
    
    Fig.ivIRFs = VAR.ivLaborVar2IRFs;
    Fig.ivIRFsL = VAR.ivLaborVar2IRFsL;
    Fig.ivIRFsH = VAR.ivLaborVar2IRFsH;
    
    Fig.labels1 = VAR.varsLbls1;
    Fig.labels2 = VAR.varsLbls2;
    Fig.subLbls1 = VAR.rfAdjR2LaborVar2;
    Fig.subLbls2 = VAR.fsFstat;
    Fig.subLbls3 = VAR.fsHetRobFstat;
end

Fig.cols = 2;
tiledlayout(ceil(Fig.numFigs/Fig.cols),Fig.cols,'TileSpacing','Compact','Padding','Compact');

for f = 1:Fig.numFigs
    nexttile
    set(gca,'FontSize',8.5)
    
    xticks(0:VAR.tsFreq:(VAR.irfHorizon-1));
    grid minor
    
    yline(0,'linewidth',0.5,'Color',"#A2142F",'LineStyle','-.');
    ylim([(round(min(Fig.ivIRFsL(:,2,f)),1) - 0.1) (round(max(Fig.ivIRFsH(:,2,f)),1) + 0.1)]);
    
    hold on
    fill([0:1:(VAR.irfHorizon-1),fliplr(0:1:(VAR.irfHorizon-1))],[Fig.ivIRFsL(:,1,f)',fliplr(Fig.ivIRFsH(:,1,f)')],[0.85,0.85,0.85],'EdgeColor','none');
    fill([0:1:(VAR.irfHorizon-1),fliplr(0:1:(VAR.irfHorizon-1))],[Fig.ivIRFsL(:,2,f)',fliplr(Fig.ivIRFsH(:,2,f)')],[0.65,0.65,0.65],'EdgeColor','none');
    
    if VAR.doCholVAR == true
        plot(linspace(0,(VAR.irfHorizon-1),VAR.irfHorizon),Fig.cholIRFs(:,f),'linewidth',1.25,'Color',"#4DBEEE",'LineStyle','--');
    end
    
    plot(linspace(0,(VAR.irfHorizon-1),VAR.irfHorizon),Fig.ivIRFs(:,f),'linewidth',1.5,'Color',"#0072BD",'LineStyle','-');
    
    if VAR.singleVAR == false
        for fr=1:VAR.irfHorizon
            if Fig.ivIRFsL(fr,1,f) > 0 && Fig.ivIRFsH(fr,1,f) > 0
                Fig.posSign(fr,f) = Fig.ivIRFs(fr,f);
                Fig.posVals(fr,f) = Fig.ivIRFs(fr,f);
            else
                Fig.posSign(fr,f) = NaN;
                Fig.posVals(fr,f) = 0;
            end
            
            if Fig.ivIRFsL(fr,1,f) < 0 && Fig.ivIRFsH(fr,1,f) < 0
                Fig.negSign(fr,f) = Fig.ivIRFs(fr,f);
                Fig.negVals(fr,f) = Fig.ivIRFs(fr,f);
            else
                Fig.negSign(fr,f) = NaN;
                Fig.negVals(fr,f) = 0;
            end
        end
        
        if contains(VAR.laborVars2{1}, 'URG')
            Fig.redSign = Fig.posSign(:,f);
            Fig.greenSign = Fig.negSign(:,f);
        else
            Fig.redSign = Fig.negSign(:,f);
            Fig.greenSign = Fig.posSign(:,f);
        end
        
        plot(linspace(0,(VAR.irfHorizon-1),VAR.irfHorizon),Fig.greenSign,'linewidth',3.5,'Color',"#77AC30",'LineStyle','-');
        plot(linspace(0,(VAR.irfHorizon-1),VAR.irfHorizon),Fig.greenSign,'.','MarkerSize',13.5,'MarkerEdgeColor',"#77AC30",'MarkerFaceColor',"#77AC30");
        plot(linspace(0,(VAR.irfHorizon-1),VAR.irfHorizon),Fig.redSign,'linewidth',3.5,'Color',"#A2142F",'LineStyle','-');
        plot(linspace(0,(VAR.irfHorizon-1),VAR.irfHorizon),Fig.redSign,'.','MarkerSize',13.5,'MarkerEdgeColor',"#A2142F",'MarkerFaceColor',"#A2142F");
    end
    hold off
    
    if VAR.singleVAR == true || f <= Fig.cols
        title(Fig.labels1(f),'FontSize',11.5);
    end
    
    if f == Fig.numFigs || f == Fig.numFigs - 1
        xlabel('months','FontSize',10,'FontWeight','bold');
    end
    
    if VAR.singleVAR == true && f ~= find(VAR.cholOrder == 1)
        subtitle(("adj R^2_V_A_R: " + Fig.subLbls1(f)),'FontSize',9);
    else
        subtitle(("adj R^2_V_A_R: " + Fig.subLbls1(f) + " | F_F_S(rob): " + Fig.subLbls2(f) +"(" + Fig.subLbls3(f) + ")"),'FontSize',9);
    end
    
    if VAR.singleVAR == false
        ylabel(Fig.labels2(f),'FontSize',10.5,'FontWeight','bold');
        
        if contains(VAR.laborVars2{1}, 'URG')
            Fig.showVals = Fig.posVals(:,f);
        else
            Fig.showVals = Fig.negVals(:,f);
        end
        
        Fig.respAvg(f) = round(mean(nonzeros(Fig.showVals)),2);
        Fig.gapAvg(f) = round(mean(VAR.gapsData(:,f)),2);
        Fig.perGap(f) = round(100*(mean(nonzeros(Fig.showVals))/mean(VAR.gapsData(:,f))),2);
        
        Fig.numFirstSignPer = find(Fig.showVals,1,'first') - 1;
        Fig.numSignPers = numel(nonzeros(Fig.showVals));
        
        text(20,((round(min(Fig.ivIRFsL(:,2,f)),1) - 0.1) + ((round(max(Fig.ivIRFsH(:,2,f)),1) + 0.1) - (round(min(Fig.ivIRFsL(:,2,f)),1) - 0.1))/10),(string(Fig.numFirstSignPer + ";" + Fig.numSignPers + " | " + Fig.respAvg(f)) + "/" + string(Fig.gapAvg(f)) + " (" + string(Fig.perGap(f)) + "%)"),'FontSize',9);
    end
end