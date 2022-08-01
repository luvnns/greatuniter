function closeRequest(app)
try
    disconnect(app);
catch
end
delete(app);
end