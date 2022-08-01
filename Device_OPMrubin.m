classdef Device_OPMrubin
    properties (Constant)
        baudRate = 9600
        powerMinLimit = -60
        dataType = "uint8"
        bit = 8
        requestCurrentWavelengthCommand = char(hex2dec('7A'))
        requestNextWavelengthCommand = char(hex2dec('7B'))
        requestPowerCommand = char(hex2dec('82'))
        unitPrefixes = {'nW','mcW','mW','W'} % if you want to change this constant, check autoSelectPrefix(obj)
    end
    properties
        name
        serialPort
        virtualObject
        wavelengthArray
        wavelengthInd
    end
    properties
        numberMeasurement
        powerdBm
        powerWsym
        time
    end
    methods
        function obj = Device_OPMrubin(appStruct)
            obj.name = appStruct.OPMname;
            obj.serialPort = appStruct.Serialport;
            obj.virtualObject = serialport(obj.serialPort,obj.baudRate);
            obj = createWavelengthArray(obj);
            obj.wavelengthInd = 1;
            obj.numberMeasurement = 0;
            obj.powerdBm = [];
            obj.powerWsym = {};
            obj.time = [];
        end
        function obj = createWavelengthArray(obj)
            obj.wavelengthArray = [];
            ind = 1;
            currentWavelength = requestCurrentWavelength(obj);
            obj.wavelengthArray(ind,1) = currentWavelength;
            currentWavelength = requestNextWavelength(obj);
            while currentWavelength ~= obj.wavelengthArray(1)
                ind = ind + 1;
                obj.wavelengthArray(ind,1) = currentWavelength;
                currentWavelength = requestNextWavelength(obj);
            end
        end
        function currentWavelength = requestCurrentWavelength(obj)
            write(obj.virtualObject,obj.requestCurrentWavelengthCommand,"char");
            response = read(obj.virtualObject,2,obj.dataType);
            currentWavelength = bitshift(response(1),obj.bit)+response(2);
        end
        function currentWavelength = requestNextWavelength(obj)
            write(obj.virtualObject,obj.requestNextWavelengthCommand,"char");
            response = read(obj.virtualObject,2,obj.dataType);
            currentWavelength = bitshift(response(1),obj.bit)+response(2);
        end
        function obj = setWavelength(obj,newWavelength)
            %newWavelength in num
            newInd = find(obj.wavelengthArray == newWavelength);
            currentWavelength = requestNextWavelength(obj);
            oldInd = find(obj.wavelengthArray == currentWavelength);
            len = length(obj.wavelengthArray);
            for i = 1:mod(len + newInd - oldInd, len)
                requestNextWavelength(obj);
            end
            obj.wavelengthInd = newInd;
        end
        function Wsym = autoSelectPrefix(obj,currentPowerdBm)
            Wsym = (10^(currentPowerdBm/10)/1000)*symunit('W');
            sNum = separateUnits(Wsym);
            Wnum = double(sNum);
            ind = length(obj.unitPrefixes);
            while Wnum < 1
                ind = ind - 1;
                newUnits = symunit(obj.unitPrefixes{ind});
                Wsym = unitConvert(Wsym,newUnits);
                sNum = separateUnits(Wsym);
                Wnum = double(sNum);
            end
        end
        function obj = requestPower(obj)
            obj.numberMeasurement = obj.numberMeasurement + 1;
            i = obj.numberMeasurement;
            obj.time(i) = now;
            write(obj.virtualObject,obj.requestPowerCommand,"char");
            response = read(obj.virtualObject,7,obj.dataType);
            currentPowerdBm = (bitshift(response(1),obj.bit)+response(2))/100;
            if response(3) == 1
                currentPowerdBm = currentPowerdBm*(-1);
            end
            if currentPowerdBm < obj.powerMinLimit
                currentPowerdBm = obj.powerMinLimit;
            end
            obj.powerdBm(i) = currentPowerdBm;
            obj.powerWsym{i} = autoSelectPrefix(obj,currentPowerdBm);
        end
        function obj = deleteVirtualObject(obj)
            flush(obj.virtualObject);
            delete(obj.virtualObject);
        end
    end
end