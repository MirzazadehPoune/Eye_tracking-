
 sId='Poune';

%% Eyelink: start

dummymode=0;
if ~EyelinkInit(dummymode, 1)
    fprintf('Eyelink Init aborted.\n');
    Eyelink('Shutdown');
    return;
end
eye_used = -1;
el=EyelinkInitDefaults(win);
Eyelink('command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA'); % open file to record data to
edfFile=[sId '.edf'];
status= Eyelink('openfile',edfFile);
if status~= 0
   error('openfile error, status: ', status); 
end
Eyelink('trackersetup');
Eyelink('startrecording');
WaitSecs(1);
Eyelink('Message', 'SYNC  TIME');

disp('1');

if Eyelink( 'NewFloatSampleAvailable') > 0
    evt = Eyelink( 'NewestFloatSample');
    if eye_used ~= -1
        x = evt.gx(eye_used+1);
        y = evt.gy(eye_used+1);
    else % if we don't, first find eye that's   being tracked
        eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
%         if eye_used == el.BINOCULAR; % if both eyes are tracked
%             eye_used = el.RIGHT_EYE; % use left eye
%         end
    end
end
% Eyelink: end
%%
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
ifi = Screen('GetFlipInterval', window);
[xCenter, yCenter] = RectCenter(windowRect);
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');


%/////////////////////////TEXT/////////////////////////////////

cd(['/media/brainlab/cad8a484-4676-4c48-9ef4-5b94b3f7d11f/ubuntu/Losers/slide']);

TImage=imread('Slide1.JPG');
TTexture= Screen('MakeTexture', window, TImage);
Screen('DrawTexture', window, TTexture, [], [], 0);

Start Trial:start
Eyelink('Message','TRIALID 0');
mes=['start trial' num2str(cnt)];
Eyelink('command','resord_status_messasge "%s"',mes);12121
Start Trial:end


Screen('Flip', window);
Tcounter=0; 
tic;

% If subjusts press the "space" key, it means that they have read the text, and they want to see the questions.

exit_KeyIdx = KbName('space');
RestrictKeysForKbCheck(exit_KeyIdx);

End Trial:start
Eyelink('Message','TRIAL_RESULT');
Eyelink('Message','trial OK');
End Trial:end

keyIsDown=0;

while(keyIsDown==0&&toc<=30)
     [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
     if(keyIsDown==1)
         responseTime(1)=toc;
     end
end

RestrictKeysForKbCheck([]);
l=keyIsDown;
 
% Question Part

for i=2:6
    Start Trial:start
    Eyelink('Message','TRIALID %d',i-1);
    mes=['start trial' num2str(cnt)];
    Eyelink('command','resord_status_messasge "%s"',mes);  ....
    start Trial:end           
    QImagekeyIsDown=0;
    QImage=imread(strcat('Slide',num2str(i),'.JPG'));
    QTexture{i}= Screen('MakeTexture', window, QImage);
    Screen('DrawTexture', window, QTexture{i}, [], [], 0);
    Screen('Flip', window);
  
    keyIsDown=0;
 
    tic;

   
    while(keyIsDown==0)
         [res_secs, score_keyCode, res_deltaSecs] = KbStrokeWait;
         keyIsDown=1;
         responseTime(i)=toc; 
    end
     if (i==6)
%          Screen('CloseAll'); 
       sca
     end
    End Trial:start
    Eyelink('Message','TRIAL_RESULT');  
    Eyelink('Message','trial OK'); 
    End Trial:end
end 

%%
RestrictKeysForKbCheck([]);
l=keyIsDown;

%******************* Quit Eyelink: start
Eyelink('StopRecording');
Eyelink('CloseFile');
try
    fprintf('Receiving data file ''%s''\n', [sId '.edf'] );
    status=Eyelink('ReceiveFile', edfFile, pwd, 1);

    if status > 0
        fprintf('ReceiveFile status %d\n', status);
    end
    if 2==exist(edfFile, 'file')
        fprintf('Data file ''%s'' can be found in ''%s''\n', [sId '.edf'], pwd );
    end
catch rdf
    fprintf('Problem receiving data file ''%s''\n', [sId '.edf'] );
    rdf;
end
Eyelink('Shutdown');
%******************* Quit Eyelink: end

sca;
   
