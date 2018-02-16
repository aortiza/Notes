%% Remove Particles

Action = get(PrtRemove,'value');

if Action
    set(PrtRemove,'String','Ok')
    
    while get(PrtRemove,'value');
        
        [x,y]=ginput(1);
        
        if get(PrtRemove,'value')
            
            [minDist,Index] = ...
                min(sqrt((Positions(:,1)-x).^2+(Positions(:,2)-y).^2));
            
            if minDist < 10
                RemoveArray = [RemoveArray;Positions(Index,:)]; %#ok<AGROW>
            end
            
            if ~isempty(RemoveArray)
            line(RemoveArray(:,1),RemoveArray(:,2),...
                'Marker','o','LineStyle','none','color','k','Parent',imax)
            end
            ParamSave.RemoveArray2 = [ParamSave.RemoveArray2;RemoveArray];
            RemoveArray = [];
            save([Name,'.mat'],'ParamSave');

        end
        
    end
    
    set(PrtRemove,'String','Remove')

else 
    
    set(PrtRemove,'String','One more Click')

end
Display