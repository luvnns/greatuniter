classdef PhotodiodeArr
    properties
        photodiodes
        tablePhotodiode
    end
    methods
        function obj = PhotodiodeArr(app)
            tablePhotodiode = readtable('tablePhotodiode.xlsx','Sheet','Array','ReadVariableNames',false);
            tablePhotodiode.Properties.VariableNames = {'Designition';'SerialNumber';'Wavelength';'AddressFPGA';'Loss';'Resistor'};
            for i = 1:height(tablePhotodiode)
                rowNumber = i;
                designation = tablePhotodiode{rowNumber,'Designition'};
                serialNumber = tablePhotodiode{rowNumber,'SerialNumber'};
                wavelength = tablePhotodiode{rowNumber,'Wavelength'};
                addressFPGA = tablePhotodiode{rowNumber,'AddressFPGA'};
                loss = tablePhotodiode{rowNumber,'Loss'};
                resistor = tablePhotodiode{rowNumber,'Resistor'};
                photodiodes(i) = Photodiode(app);
            end
        end
        %         function
        %
        %         end
    end
end