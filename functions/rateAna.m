function [ anaStruct ] = rateAna( dataStruct, anaStruct, factFields, lock, lAttice, varargin)
% find msrate for sets within a data structure 
% calculates average within the group and SEM 
% INPUT:
% dataStruct - structure of EM data and trial data
% anaStruct - structure of parameters defining plots and subgroups 
% lock - event number used to temporally coregister all trials 
% varargin - pass a true logical and label structure inorder to plot the results as well (incomplete) 
            % preLock - period before the lock point to include in analysis 
            % postLock - period after the lock point to include in analysis 
% OUTPUT :
% anaStruct - the same struct with an additional field of 'results' 
% varargout - future addition with figure handles etc. 

            % % set some necessary values
            % nEvents = length(dataStruct(1).events);
          
            % if lock==0
            %     WBmax=0;
            %     WAmax=max([dataStruct.events]);
            % else
            %     WBmax= max(need(dataStruct,'',lock,'events')); % max window before lock
            %     WAmax= max(need(dataStruct,'',nEvents,'events')...
            %         -need(dataStruct,'',lock,'events')); % max window after lock
            %     %
            %     %                 WAmax= round(quantile(need(sElect,'',nEvents,'events')...
            %     %             -need(sElect,'',lock,'events'), .9)); % max window after lock
            % end
            % lAttice=1-WBmax:WAmax; % longest possible timeline
  [cIndx, cLegs] =factIndx(dataStruct, {'obs', factFields{:}}); % get indexes for fields of interest
  tPointsMax=length(lAttice); % max possible timepoints

% IDlist=unique({dataStruct.obs});
for figN=length(anaStruct):-1:1 % for each of the separate figures
    anaStruct(figN).results.iRates=cell(anaStruct(figN).nGrps,1); % cell of rate results for each condition in figure
    %         rAteArrays=cell(anaStruct(fig).nGrps,1); % cell of rate results for each condition in figure
    %             AvRate=nan(tPointsMax);  % averaged rate data
    anaStruct(figN).results.rateSEM=nan(tPointsMax,1,anaStruct(figN).nGrps); % Standard error of rate data
    %         rSEM=nan(tPointsMax,1,anaStruct(fig).nGrps); % Standard error of rate data
    
    
    for groupN= anaStruct(figN).nGrps:-1:1 % for each of the separte groupings in each figure
        anaStruct(figN).results.iRates{groupN}=nan(tPointsMax, anaStruct(figN).group(groupN).nMems);  % calculated rate data
        %             rAteArrays{G}=nan(tPointsMax, anaStruct(fig).group(G).nMems);  % calculated rate data
        %             tempResults=cell(1,2); % temp storage of rate & scale
        %             [tempRate, tempScale]=deal({});
        
        for subjectN=1:anaStruct(figN).group(groupN).nMems
            % index of all trials in given condition for a particular observer
            tIndx= anaStruct(figN).Indx(groupN,:) ...    % index of of condition
                & cIndx.obs...                  % observer index
                { strcmp( anaStruct(figN).group(groupN).members(subjectN), cLegs.obs) }'; % which observer
            
            % get rate, scale, & xlims
            [tempRate, tempScale]=... % assign: rate, scale & cutoffs
                getMSrate(dataStruct(tIndx),lock); % pass selected trials with lock field
            
            % situate rate into rateArrays
            anaStruct(figN).results.iRates{groupN}... % for pConds{fig}
                ( find(lAttice==tempScale(1)) : find(lAttice==tempScale(end)),... % scale range
                subjectN)... % for IDlist(sub) & set (con)
                =tempRate(:); % assign calculated rate
        end
        
    end
    
    %     xBounds=[max(max(lims(:,:, 1))), min(min(lims(:,:,2)))]; % get most conservative limits
    % get indexs corresponding to these limits

    
    tempAvRate=cellfun(@(indRates) nanmean(indRates,2), anaStruct(figN).results.iRates,'UniformOutput', 0);
    %         anaStruct(fig).results.iRate=rAteArrays;
    anaStruct(figN).results.avRate=[tempAvRate{:}];
    tempSEM= cellfun(@(rateArray) nanstd(rateArray,0,2)./sqrt(anaStruct(figN).group(groupN).nMems),...
        anaStruct(figN).results.iRates,'UniformOutput', 0);
    tempSEM= [tempSEM{:}];
    anaStruct(figN).results.rateSEM(:)=tempSEM(:);
%     %% plotting
% %     if yesPLOT
%     beginInd=find(lAttice==-preLock);
%     endInd=find(lAttice==postLock);
%     figure; %clf;
%     [hLine{figN},hPatch{figN}]=boundedline(lAttice(beginInd:endInd),...
%         anaStruct(figN).results.aRate(beginInd:endInd,:),...
%         anaStruct(figN).results.STD(beginInd:endInd,1,:),...
%         'transparency', .3, 'alpha'); hold on;
%     set(hLine{figN}, 'HandleVisibility','off');
%     
% %     set(hLine{figN}(1),'Color', LAB.col.Attn);
% %     set(hPatch{figN}(1),'FaceColor', LAB.col.Attn);
% %     
% %     set(hLine{figN}(2),'Color', LAB.col.Neut );
% %     set(hPatch{figN}(2),'FaceColor', LAB.col.Neut );
%     
%     % make pretty
%     legend(anaStruct(figN).legend,'Location','NorthWest')
%     ylabel('Rate (Hz)');
%     xlabel(sprintf('Time (ms)'))
%     xlim([-preLock postLock]) % xBounds{fig})
% %     ylim([0 5])
%     grid
%     %    event labeling
%     title(sprintf('%s (%s locked)', anaStruct(figN).titles, LAB.events(lock)) )
%     plotEvents(dataStruct,lock,preLock,postLock,[LAB.events]);
%     
%     end
  
end

% if nargout>1 % && yesPLOT
%     varargout{1}=hLine;
%     varargout{2}=hPatch;
% end


end

