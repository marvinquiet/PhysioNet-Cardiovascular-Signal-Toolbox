function filename = GenerateHRVresultsOutput(sub_id,windows_all,results,titles,type,HRVparams, tNN, NN)
%   
%   GenerateHRVresultsOutput(sub_id,windows_all,results,titles,type,HRVparams, tNN, NN)
%
%   OVERVIEW:   Generates output based on the selections in struct HRVparams.
%
%   INPUT:      sub_id       :
%               windows_all  :
%               results      :
%               titles       :
%               type         : 'AF' results of AF detection 
%                              'MSE' results of Multoiscale Entropy
%                               [] otherwise
%               HRVparams    : struct of settings for hrv_toolbox analysis
%               tNN          : the time indices of the rr interval data (seconds)
%               NN           : a single row of NN (normal normal) interval
%                              data in seconds
%
%   OUTPUT:    filename      : current name of the file 
%              Outputs csv files or mat files based on the user's HRVparams   
%
%   DEPENDENCIES & LIBRARIES:
%       HRV_toolbox https://github.com/cliffordlab/hrv_toolbox
%       WFDB Matlab toolbox https://github.com/ikarosilva/wfdb-app-toolbox
%       WFDB Toolbox https://physionet.org/physiotools/wfdb.shtml
%   REFERENCE: 
%	REPO:       
%       https://github.com/cliffordlab/hrv_toolbox
%   ORIGINAL SOURCE AND AUTHORS:     
%       Script written by Adriana N. Vest
%       Dependent scripts written by various authors 
%       (see functions for details)       
%	COPYRIGHT (C) 2016 
%   LICENSE:    
%       This software is offered freely and without warranty under 
%       the GNU (v3 or later) public license. See license file for
%       more information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%

% What class of data is sub_id
if ischar(sub_id)
end
if isnumeric(sub_id)
    sub_id = num2str(sub_id);
end
if iscell(sub_id)
    sub_id = char(sub_id);
end


%% Establish Filename Based on Type of Output
if strcmp(type,'AF')
    filename = ['AF_results_' sub_id];
    if strcmp(HRVparams.output.format,'csv')
        % Add .csv extension to filename and directory
        fullfilename = [HRVparams.writedata filesep filename '.csv'];

        variables_names = titles;
        variables_vals = results;

        % Print out all the variables for all
        % the time windows
        for v = 1:1:length(variables_names)
            % putting variable into format acceptable for csv file
            var_formatted_for_output = variables_vals(:,v);
            fid=fopen(fullfilename,'at');
            fprintf(fid,'%s,%s,',sub_id,char(variables_names{v}));
            if length(variables_vals) > 1
                fprintf(fid,'%f,',var_formatted_for_output(1:end-1));
            end
            fprintf(fid,'%f',var_formatted_for_output(end));
            fprintf(fid,'\n');
            fclose(fid);
        end
    elseif strcmp(HRVparams.output.format,'mat')
        % Add .mat extension to filename and directory
        fullfilename = [HRVparams.writedata filesep filename '.mat'];
    
        save(fullfilename, 'results', 'titles');
	else
            % Return nothing.
    end

% 08-24-2017 -- MSE type added by GDP to generate output for Multiscle entropy 
elseif strcmp(type, 'MSE')                        
    filename = ['MSE_results_' sub_id];
    if strcmp(HRVparams.output.format,'csv')
        % Add .csv extension to filename and directory
        fullfilename = [HRVparams.writedata filesep filename '.csv'];

        variables_names = titles;
        variables_vals = results;

        % Print out all the variables for all
        % the time windows
        for v = 1:1:length(variables_names)
            % putting variable into format acceptable for csv file
            var_formatted_for_output = variables_vals(:,v);
            fid=fopen(fullfilename,'at');
            fprintf(fid,'%s,%s,',sub_id,char(variables_names{v}));
            if length(variables_vals) > 1
                fprintf(fid,'%f,',var_formatted_for_output(1:end-1));
            end
            fprintf(fid,'%f',var_formatted_for_output(end));
            fprintf(fid,'\n');
            fclose(fid);
        end
    elseif strcmp(HRVparams.output.format,'mat')
        % Add .mat extension to filename and directory
        fullfilename = [HRVparams.writedata filesep filename '.mat'];
    
        save(fullfilename, 'results', 'titles');
	else
            % Return nothing.
    end
      
else
    if ~isempty(HRVparams.output.num_win) 
        x = size(results);
        idx = find(length(titles) == x);
        x(3-idx);   % if titles are in row : idx = row(1), this will return x(2)
                    % if titles are in col : idx = col(2), this will return x(1)
        num_results = x(3-idx);
        
        if num_results > 1
            filename = ['HRV_results_' num2str(HRVparams.output.num_win) 'windows_' HRVparams.time];
        else
            filename = ['HRV_results_' HRVparams.time];
        end
        
        if HRVparams.output.separate
            % Generate a new file for each output
            fullfilename = [filename '_patid' sub_id];
        end
    elseif isempty(HRVparams.output.num_win) 
        filename = ['HRV_results_allwindows_allpatients_' HRVparams.time];

        if HRVparams.output.separate
            % Generate a new file for each output
            filename = ['HRV_results_allwindows_patid' sub_id];
        end
    end


    if strcmp(HRVparams.output.format,'csv')
        % Add .csv extension to filename
        fullfilename = [HRVparams.writedata filesep filename '.csv'];
    
        if ~isempty(HRVparams.output.num_win) 
            % Returns results based on the number of windows set by the
            % HRVparams file
            
            x = size(results);
            idx = find(length(titles) == x);
            x(3-idx);   % if titles are in row : idx = row(1), this will return x(2)
                        % if titles are in col : idx = col(2), this will return x(1)
            num_results = x(3-idx);
            
            % Find num_win windows with the lowest HR
            if num_results > 1
                windows_output = FindLowestHRwin(windows_all,tNN, NN, HRVparams.output.num_win,HRVparams);

                for i = 1:HRVparams.output.num_win
                    windx(i) = find(windows_output(i).t == windows_all);  
                end

                variables_names = titles;
                variables_vals = results(windx,:);
            else
                variables_names = titles;
                variables_vals = results;
            end
            % Print out all the variables for all
            % the time windows
            for v = 1:1:length(variables_names)
                % putting variable into format acceptable for csv file
                var_formatted_for_output = variables_vals(:,v);
                fid=fopen(fullfilename,'at');
                fprintf(fid,'%s,%s,',sub_id,variables_names{v});
                if length(variables_vals) > 1
                    fprintf(fid,'%f,',var_formatted_for_output(1:end-1));
                end
                fprintf(fid,'%f',var_formatted_for_output(end));
                fprintf(fid,'\n');
                fclose(fid);
            end
                
        elseif isempty(HRVparams.output.num_win) 
        
            %filename = [HRVparams.time '_allwindows_results.csv'];
            % Print out all the window values for all variables
            variables_names = titles;
            variables_vals = results;

            % We need to print out all the variables for all
            % the time windows
            for v = 1:1:length(variables_names)
                % putting variable into format acceptable for csv file
                var_formatted_for_output = variables_vals(:,v);
                fid=fopen(fullfilename,'at');
                fprintf(fid,'%s,%s,',sub_id,variables_names{v});
                fprintf(fid,'%f,',var_formatted_for_output(1:end-1));
                fprintf(fid,'%f',var_formatted_for_output(end));
                fprintf(fid,'\n');
                fclose(fid);
            end
        else
            % Do nothing.
        end % End decision based on number of windows needed to be returned

    elseif strcmp(HRVparams.output.format,'mat')
        % Add .mat extension to filename
        fullfilename = [HRVparams.writedata filesep filename '.mat'];
    
        if ~isempty(HRVparams.output.num_win)
            windows_output = FindLowestHRwin(tNN, NN,HRVparams.output.num_win);

            for i = 1:HRVparams.output.num_win
                windx(i) = find(windows_output(i).t ==  windows_all);  
            end

            output = results(wind,:);
            save(fullfilename, 'output','titles');

        elseif isempty(HRVparams.output.num_win) 

            save(fullfilename, 'results', 'titles');
        else
        end
    else
        % Return nothing.
    end
end

% % % save plot of results
% % %if HRVparams.save_figs
% %     figfilename = ['NN_Interval_' record.record];% create filename string
% %     figfile = fullfile(writedirectory, record.record, figfilename);
% %     savefig(figfile); % Saving figure
% %     close(figure)
% % %end

% The following code picks the window with the lowest median HR and
% prints the output in SAP ready format

% windows_output = FindLowestHRwin(tNN, NN, HRVparams.numsegs);



end
%% Print titles at top of file
%     fid=fopen(filename,'wt');
%     [rows,cols]=size(titles);
%     for i=1:1545 % MODIFIED TO ACCOMODATE TWINS DATA
%         which is 1545 windows long at longest patient file
%         fprintf(fid,'%s,',titles{i,1:end-1});
%         fprintf(fid,'%s\n',titles{i,end});
%     end
%     fclose(fid);

%         if i_patient == 1        
%            % titles = {'i_patient','patient_ID','i_win','ac', 'dc', 'ulf', 'vlf', 'lf', 'hf', 'lfhf', 'ttlpwr', 'fdflag', 'NNmean', 'NNmedian','NNmode','NNvariance','NNskew','NNkurt', 'SDNN', 'NNiqr', 'RMSSD','pnn50'};
%            fid=fopen(filename,'wt');
%            [rows,cols]=size(col_titles);
%            for i=1:rows
%                  fprintf(fid,'%s,',titles{i,1:end-1});
%                  fprintf(fid,'%s\n',titles{i,end});
%            end
%            fclose(fid)
%         end
        % dlmwrite(filename,output,'delimiter',',','-append');

% for i = 1:s.numsegs
%    wind(i) = find(t_win > windows_output(i).t & t_win < windows_output(i).t + s.increment);
% end
% output = [i_patient,subjectids(i_patient),i_win(wind), ac(wind), dc(wind), ulf(wind), vlf(wind), lf(wind), hf(wind), ...
%    lfhf(wind), ttlpwr(wind), flag(wind), NNmean(wind), NNmedian(wind), ...
%    NNmode(wind), NNvariance(wind), NNskew(wind), NNkurt(wind), SDNN(wind), NNiqr(wind), ...
%    RMSSD(wind), pnn50(wind)];
% if i_patient == 1        
%    titles = {'i_patient','patient_ID','i_win','ac', 'dc', 'ulf', 'vlf', 'lf', 'hf', 'lfhf', 'ttlpwr', 'flag', 'NNmean', 'NNmedian','NNmode','NNvariance','NNskew','NNkurt', 'SDNN', 'NNiqr', 'RMSSD','pnn50'};
%    fid=fopen(filename,'wt');
%    [rows,cols]=size(titles);
%    for i=1:rows
%          fprintf(fid,'%s,',titles{i,1:end-1});
%          fprintf(fid,'%s\n',titles{i,end});
%    end
% end
% 
% dlmwrite(filename,output,'delimiter',',','-append');