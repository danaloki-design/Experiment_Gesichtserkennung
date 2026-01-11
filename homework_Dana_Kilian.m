clear;
clc;
Screen('CloseAll');
KbReleaseWait;

cd(fileparts(mfilename('fullpath')));

%Fenster öffnen 
[width, height] = Screen('WindowSize', max(Screen('Screens')));
winRect = [0 0 round(width*0.99) round(height*0.99  )];  
myWindow = Screen('OpenWindow', max(Screen('Screens')), [128 128 128], winRect); 

white = WhiteIndex(myWindow);  
black = BlackIndex(myWindow);   
gray  = (white + black)/2;
Screen('TextSize', myWindow, 40);

%Bilder laden 
famousFiles    = dir('Famous/*.jpg');
nonfamousFiles = dir('Non-famous/*.jpg');

length(famousFiles)
length(nonfamousFiles) 

nTrials = 50;  
RT = zeros(nTrials,1);

% Zähl-Arrays für Maximal 2 Wiederholungen pro Bild
famousCount    = zeros(length(famousFiles),1);     
nonfamousCount = zeros(length(nonfamousFiles),1);  
maxRepeats = 2;   

%Instruktionstext
instrText = ['Im Verlauf des Versuchs werden Ihnen verschiedene Bilder von Personen präsentiert.\n\n' ...
             'Diese Bilder sollen Sie entweder zu Famous (Pfeil nach oben) oder\n' ...
             'non-Famous (Pfeil nach unten) zuordnen.\n\n' ...
             'Betätigen Sie erst eine der beiden Pfeiltasten, wenn der Bildschirm\n' ...
             'nach dem eingeblendeten Bild wieder völlig grau ist.\n\n' ...
             'Drücken Sie die Leertaste, um weiter zu fahren.']; 

Screen('TextSize', myWindow, 24);
DrawFormattedText(myWindow, instrText, 'center', 'center', white);
Screen('Flip', myWindow);

pressed = 0;
while ~pressed
    [keyIsDown, ~, keyCode] = KbCheck;
    if keyIsDown && keyCode(KbName('space'))
        pressed = 1;
    end
end

%TRIAL LOOP (für 50 Trials)
for t = 1:nTrials
    
    %Fixationskreuz für 2 Sekunden 
    DrawFormattedText(myWindow, '+', 'center', 'center', black);
    Screen('Flip', myWindow);
    WaitSecs(2);

    %Mask/Noisy Square 
    noise = rand(200,200)*255;
    Screen('FillRect', myWindow, gray);
    noiseTex = Screen('MakeTexture', myWindow, noise);
    Screen('DrawTexture', myWindow, noiseTex);
    Screen('Flip', myWindow); 
    WaitSecs(0.2 + rand*0.3);

    %Zufälliges Gesicht (maximal 2 Wiederholungen) 
    valid = 0;
    while ~valid
        if rand > 0.5
            % Famous
            validIdx = find(famousCount < maxRepeats);
            idx = validIdx(randi(length(validIdx)));
            fpath = fullfile('Famous', famousFiles(idx).name);
            correct = 'UpArrow';
            famousCount(idx) = famousCount(idx) + 1;
        else
            % Non-Famous
            validIdx = find(nonfamousCount < maxRepeats);
            idx = validIdx(randi(length(validIdx)));
            fpath = fullfile('non-Famous', nonfamousFiles(idx).name);
            correct = 'DownArrow';
            nonfamousCount(idx) = nonfamousCount(idx) + 1;
        end

        try
            img = imread(fpath);
            valid = 1;
        catch
            fprintf('Ungültige Datei übersprungen: %s\n', fpath);
            valid = 0;
        end
    end 

    %Bild anzeigen 
    faceTex = Screen('MakeTexture', myWindow, img);
Screen('DrawTexture', myWindow, faceTex); 
tStart = Screen('Flip', myWindow);

     WaitSecs(2);  
     
    Screen('FillRect', myWindow, gray);
    Screen('Flip', myWindow);

    %Reaktionszeit messen 
    pressed = 0;
    while ~pressed
        [keyIsDown, secs, keyCode] = KbCheck;
        if keyIsDown
            RT(t) = secs - tStart;
            pressed = 1;
        end
    end

end

%Resultate  
meanRT = mean(RT);
disp(['Mean RT: ', num2str(meanRT), ' s']);

KbWait;
Screen('CloseAll');
