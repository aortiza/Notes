%% Add Particles

Action = get(PrtAdd,'value');

if Action
    set(PrtAdd,'String','Ok')
    
    while get(PrtAdd,'value')
        [x,y] = ginput(1);
        if get(PrtAdd,'value')
            
            if ~(any([x+50,y]<0)||any([x-50,y]>size(I')))
            AddArray = [AddArray;[x,y]]; %#ok<AGROW>
            end
            if ~isempty(AddArray)
            line(AddArray(:,1),AddArray(:,2),...
                'Marker','o','LineStyle','none','color','r','Parent',imax)
            end
        end
    end
    ParamSave.AddArray2 =  [ParamSave.AddArray2;AddArray];
    AddArray = [];
    
    set(PrtAdd,'String','Add')
    save([Name,'.mat'],'ParamSave');
    
else
    
    set(PrtAdd,'String','One more Click')

end

Display