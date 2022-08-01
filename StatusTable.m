classdef StatusTable
    properties (Constant)
        FIGURE_NAME = 'Status table'
        FIGURE_POSITION = [20,150,1000,800]
        UITABLE_UNITS = 'normalized'
        UITABLE_POSITION = [0.01, 0.01, 0.99, 0.99]
        UITABLE_BACKGROUND_SECOND_COLOR = [0.96,0.96,1]
        UITABLE_FONT_SIZE = 16
        UITABLE_COLUMN_WIDTH = 'fit'
    end
    properties
        fig
        uit
    end

    methods
        function obj = StatusTable(testTable)
            obj.fig = uifigure('Name',obj.FIGURE_NAME);
            obj.fig.Position = obj.FIGURE_POSITION;
            obj.uit = uitable(obj.fig,'Data',testTable);
            obj.uit.Units = obj.UITABLE_UNITS;
            obj.uit.Position = obj.UITABLE_POSITION;
            obj.uit.BackgroundColor(2,:) = obj.UITABLE_BACKGROUND_SECOND_COLOR;
            obj.uit.FontSize = obj.UITABLE_FONT_SIZE;
            obj.uit.ColumnWidth = obj.UITABLE_COLUMN_WIDTH;
        end
        function obj = refreshTable(obj,newTable)
            obj.uit.Data = newTable;
        end
        function logic = isvalidFigure(obj)
            logic = isvalid(obj.fig);
        end
    end
end