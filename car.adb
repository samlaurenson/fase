package body car with SPARK_Mode is
   
   procedure KeyInserted is
   begin
      if myCar.carKey = Absent then
         myCar.carKey := Present;
      end if;
   end KeyInserted;
   
   procedure KeyRemoved is
   begin
      if myCar.carKey = Present and myCar.gear = Parked then
         myCar.carKey := Absent;
      end if;
   end KeyRemoved;

   procedure TurnOnCar is
   begin
      if myCar.power = Off and myCar.carKey = Present and myCar.gear = Parked then
         myCar.permitted := PermittedToDrive(myCar.battery); --will check if the car can be driven (if there is enough charge in the battery)
         myCar.power := On;
         --myCar.permitted := PermittedToDrive(myCar.battery); --will check if the car can be driven (if there is enough charge in the 
      end if;
   end TurnOnCar;
   
   procedure TurnOffCar is
   begin
      if myCar.power = On and myCar.gear = Parked then
         myCar.power := Off;
      end if;
   end TurnOffCar;
   
   function PermittedToDrive (charge : in BatteryRange) return Boolean is
   begin
      if charge >= minimumBatteryCharge then
         return True;
      else
         return False;
      end if;
   end PermittedToDrive;
   
   procedure ChangeGear (gearSwitch : in GearSettings) is
   begin
      --  if myCar.diagnosticMode = Off and ((gearSwitch = Parked and myCar.speed = SpeedRange'First) or (myCar.gear = Parked and myCar.permitted) or (myCar.gear = Driving and myCar.permitted) or (myCar.gear = Reversing and myCar.permitted)) then
      --     --myCar.gear := gearSwitch;
      --  
      --     if ((myCar.gear = Driving or myCar.gear = Reversing) and gearSwitch = Parked and myCar.speed = 0) or
      --     (myCar.gear = Parked and (gearSwitch = Driving or gearSwitch = Reversing)) then
      --        myCar.gear := gearSwitch;
      --     end if;
      --  end if;
      
      if (((myCar.gear = Driving or myCar.gear = Reversing) and gearSwitch = Parked and myCar.diagnosticMode = Off) or 
                                           (myCar.gear = Parked and (gearSwitch = Driving or gearSwitch = Reversing) and myCar.permitted and myCar.diagnosticMode = Off and not WarningLightIsOn(SeatbeltUnplugged))) then
         myCar.gear := gearSwitch;
      end if;
   end ChangeGear;
   
   procedure IncreaseSpeed is
   begin
      if myCar.power = On and myCar.gear /= Parked and myCar.speed < SpeedRange'Last and myCar.speed < myCar.limit and myCar.sensors = Clear then
         myCar.speed := myCar.speed + 1;
      end if;
   end IncreaseSpeed;
   
   procedure DecreaseSpeed is
   begin
      if myCar.power = On and myCar.gear /= Parked and myCar.speed > SpeedRange'First then
         myCar.speed := myCar.speed - 1;
      end if;
   end DecreaseSpeed;
  
   procedure ObjectHasGone is
   begin
      if myCar.sensors = Detected and myCar.power = On and obstacles = Absent then
         myCar.sensors := Clear;
      end if;
   end ObjectHasGone;
   
   procedure SensorsActivated is
   begin
      if myCar.diagnosticMode = Off and myCar.sensors = Clear and myCar.speed >= 0 then
         myCar.sensors := Detected;
      
         while myCar.speed > SpeedRange'First loop
            if myCar.power = On and myCar.gear /= Parked and myCar.diagnosticMode = Off then
               DecreaseSpeed;
            end if;
         end loop;
         
      
         --maybe take this bit out if need to do diagnostic mode for gear changes
         --then just need to add myCar.diagnosticMode = Off for all gear change preconditions
         --  if myCar.diagnosticMode = Off then
         --     ChangeGear(Parked);
         --  end if;
         
      end if;
   end SensorsActivated; 
  
   
   procedure CheckForObstacles is
   begin
      if myCar.power = On and myCar.diagnosticMode = Off and myCar.speed >= 0 and ((obstacles = Present and myCar.sensors = Clear) or (obstacles = Absent and myCar.sensors = Detected)) then
         if obstacles = Present then
            SensorsActivated;
         else 
            ObjectHasGone;
         end if;
      end if;
   end CheckForObstacles;
   

   procedure EnableDiagnosticMode is
   begin
      if myCar.power = On and myCar.gear = Parked and myCar.diagnosticMode = Off then
         myCar.diagnosticMode := On;
      end if;
   end EnableDiagnosticMode;
   
   procedure DisableDiagnosticMode is
   begin
      if myCar.power = On and myCar.gear = Parked and myCar.diagnosticMode = On then
         myCar.diagnosticMode := Off;
      end if;
   end DisableDiagnosticMode;
   
   procedure SetSpeedLimit (newLimit : SpeedRange) is
   begin
      if myCar.power = On and myCar.limit /= newLimit then
         myCar.limit := newLimit;
      end if;
   end SetSpeedLimit;
   
   function CountWarningLights return WarningsIndex is
      counter : WarningsIndex := 0;
   begin
      for I in myCar.wlights'Range loop
         if myCar.wlights(I) /= None and counter < WarningsIndex'Last then
            counter := counter + 1;
         end if;
      end loop;
      return counter;
   end CountWarningLights;
   
   procedure TurnOnWarningLight (warning : Warnings) is 
   begin
      if myCar.power = On and warning /= None and WarningLightIsOn(warning) = False and CountWarningLights < WarningsIndex'Last then
         myCar.wlights(CountWarningLights) := warning;
      end if;
   end TurnOnWarningLight;
   
   procedure TurnOffWarningLight (warning : Warnings) is
      tempLights : WarningLights := (others => None);
      increment : WarningsIndex := 0;
   begin
      if myCar.power = On and WarningLightIsOn(warning) and warning /= None then
         --Extracting all the warning lights to not turn off from car warning lights array
         --Putting the values in a temporary array - which also helps overcome the issue of gaps being left
         --in the cars warning lights array (e.g. SeatbeltUnplugged, None, BatteryLow), which would be problematic with the
         --way lights are added to the warning array
         for I in myCar.wlights'Range loop
            if myCar.wlights(I) /= warning and myCar.wlights(I) /= None then
               tempLights(increment) := myCar.wlights(I);
               increment := increment + 1;
            end if;
         end loop;
      
         myCar.wlights := tempLights;
      end if;
   end TurnOffWarningLight;
   
   procedure EnableBatteryLight is
   begin
      if myCar.power = On and myCar.battery <= 15 and not WarningLightIsOn(BatteryLow) and CountWarningLights < WarningsIndex'Last then
         TurnOnWarningLight(BatteryLow);
      else 
         TurnOffWarningLight(BatteryLow);
      end if;
   end EnableBatteryLight;
   
   procedure EnableSeatbeltLight is 
   begin
      if myCar.power = On and PassengerWithoutSeatbelt and not WarningLightIsOn(SeatbeltUnplugged) and CountWarningLights < WarningsIndex'Last then
         TurnOnWarningLight(SeatbeltUnplugged);
      else
         TurnOffWarningLight(SeatbeltUnplugged);
      end if;
   end EnableSeatbeltLight;
   
   function CountPassengers return SeatIndex is
      counter : SeatIndex := 0;
   begin
      for I in myCar.seats'Range loop
         if myCar.seats(I).passenger /= Absent and counter < CarSeats'Last then
            counter := counter + 1;
         end if;
      end loop;
      return counter;
   end CountPassengers;
   
   procedure AddPassenger is
   begin
      if CheckForEmptySeats and myCar.speed = 0 then
         for I in myCar.seats'Range loop
            if myCar.seats(I).passenger = Absent then
               myCar.seats(I).passenger := Present;
               exit;
            end if;
         end loop;
      end if;
   end AddPassenger;
   
   procedure RemovePassenger (index : SeatIndex) is 
   begin
      if CountPassengers > 0 and myCar.seats(index).passenger = Present and myCar.speed = 0 then
         myCar.seats(index).passenger := Absent;
      end if;
   end RemovePassenger;
   
   
end car;
