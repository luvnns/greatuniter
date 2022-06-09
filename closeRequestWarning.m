function closeRequestWarning(app,fig)
confirmText = "Do you want to save input data before exit?";
answer = uiconfirm(fig,confirmText,"Confirm save", ...
    "Options",["Save" "Exit" "Cancel"],...
    'DefaultOption',"Save",'CancelOption',"Cancel",...
    'Icon','gu_help.png');
if answer == "Save"
    saveFromAppToMemFile(app);
end
if answer == "Save" || answer == "Exit"
    disconnect(app);
    delete(app);
end
end