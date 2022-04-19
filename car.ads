package car with SPARK_Mode is
   
   --Could split in to different files for - Gear Settings, Driving and Speed, Warnings
   
   --car can only be turned on when in parked mode
   
   type Key is (Present, Absent);
   
   type OnOff is (On, Off);
   
   type GearSettings is (Parked, Driving, Reversing);
   
   type BatteryRange is range 0..100; --percentage of battery in car
   
   type SpeedRange is range 0..80;
   
   type SensorsDetected is (Detected, Clear);
   
   type ObstaclePresence is (Present, Absent);
   
   --  type WarningIndex is range 0..5;
   --  
   --  type Warnings is (None, BatteryLow);
   --  
   --  type WarningLights is array (Index) of Warnings;
   
   --could have a variable that tracks what index of the warning light array can have a warning inserted in to
   --would have to first check the warning is not already in the array
   --also need a method to remove a warning from the array (then move every other warning down in the array?)
   --could use a while - for the current (removed item) index and indexes after (while index+1 is not "None"), move the item in index+1 to index
   --this would help the extensibility of the warning system
   
   type PassengerPresence is (Present, Absent);
   type SeatbeltPlugged is (Plugged, Unplugged);
   
   type SeatIndex is range 0..5;
   
   type CarSeat is record
      passenger : PassengerPresence;
      seatbelt : SeatBeltPlugged;
   end record;
   
   type CarSeats is array (SeatIndex) of CarSeat;
   
   type WarningsIndex is range 0..5;
   type Warnings is (None, BatteryLow, SeatbeltUnplugged);
   type WarningLights is array (WarningsIndex) of Warnings;
   
   --not sure if speed limit should be part of car or a global variable
   --type SpeedLimit is range 0..80;
   --limit : SpeedLimit := 50;
   
   --Would make sense to have limit as part of the car's speed range (since the car would not be able to exceed limit if the limit was higher than the cars range
   -- so it would automatically meet that requirement)
   --limit : SpeedRange := 0;
   obstacles : ObstaclePresence := Absent;
   minimumBatteryCharge : BatteryRange := 10;
   
   --batteryWarning : OnOff;
   --   seatbeltWarning: OnOff;
   
   type Car is record
      carKey : Key;
      power : OnOff;
      limit : SpeedRange;
      permitted : Boolean;
      gear : GearSettings;
      battery : BatteryRange;
      speed : SpeedRange;
      diagnosticMode : OnOff;
      seats : CarSeats;
      wlights : WarningLights;
      sensors : SensorsDetected;
   end record;
   
   --Diagnostic mode for all pre conditions? not sure what "any other operation" is 
   
   myCar : Car := (carKey => Absent,
                   power => Off, 
                   limit => 0,
                   permitted => False, 
                   gear => Parked, 
                   battery => 14, 
                   speed => 0,  
                   diagnosticMode => Off, 
                   sensors => Clear,
                   wlights => (others => None),
                   seats => (others => (passenger => Absent, seatbelt => Unplugged)));
   
   function Invariant return Boolean is
     (myCar.speed <= myCar.limit); --always want the car to follow the speed limit
   
   --always want the car to be on and less than the speed limit
   
   procedure KeyInserted with
     Global => (In_Out => myCar),
     Pre => myCar.carKey = Absent,
     Post => myCar.carKey = Present;
   
   procedure KeyRemoved with
     Global => (In_Out => myCar),
     Pre => myCar.carKey = Present and myCar.gear = Parked,
     Post => myCar.carKey = Absent;
   
   procedure SetSpeedLimit (newLimit : SpeedRange) with
     Global => (In_Out => myCar),
     Pre => myCar.power = On and myCar.limit /= newLimit,
     Post => myCar.limit = newLimit;
   
   procedure TurnOnCar with
     Global => (In_Out => myCar, Input => minimumBatteryCharge),
     Pre => myCar.power = Off and myCar.carKey = Present and myCar.gear = Parked,
     Post => myCar.power = On;
   
   procedure TurnOffCar with
     Global => (In_Out => myCar),
     Pre => myCar.gear = Parked and myCar.power = On,
     Post => myCar.power = Off;
   
   --Function to set "permitted" flag after turning on the car
   --If flag is true - car can be driven. If false - car can't be driven
   --Purpose is to prevent car from being unable to change gears if the car goes below the 
   --battery charge required to drive the car.
   --So if the flag is true (car had enough charge when started), this allows the driver to drive the car until the battery runs out of charge
   function PermittedToDrive (charge : in BatteryRange) return Boolean with
     Global => (Input => minimumBatteryCharge);
   
   --To change from Drive to Reverse, the car must first be in 'Parked' gear
   --Gear change to Parked will always be fine - Also ensures that car cannot go from Drive to Reverse
   --Due to the Precondition that if the gearSwtich is not to 'Parked' - then the car must first be in parking gear and has been flagged as having enough charge to drive
   procedure ChangeGear (gearSwitch : in GearSettings) with
     Global => (In_Out => myCar),
     Pre => ((myCar.gear = Driving or myCar.gear = Reversing) and gearSwitch = Parked and myCar.diagnosticMode = Off) or (myCar.gear = Parked and (gearSwitch = Driving or gearSwitch = Reversing) and myCar.permitted and myCar.diagnosticMode = Off and not WarningLightIsOn(SeatbeltUnplugged)),
     Post => myCar.gear = gearSwitch;
     
     --Pre => myCar.diagnosticMode = Off and ((gearSwitch = Parked and myCar.speed = SpeedRange'First) or (myCar.gear = Parked and myCar.permitted) or (myCar.gear = Driving and myCar.permitted) or (myCar.gear = Reversing and myCar.permitted)),
     --Post => myCar.gear = gearSwitch;
   
   --and myCar.diagnosticsMode = Off (in precondition)
   procedure IncreaseSpeed with
     Global => (In_Out => myCar),
     Pre => myCar.power = On and myCar.gear /= Parked and myCar.speed < SpeedRange'Last and myCar.speed < myCar.limit and myCar.sensors = Clear,
     Post => myCar.speed > myCar'Old.speed and Invariant;
   
   procedure DecreaseSpeed with
     Global => (In_Out => myCar),
     Pre => myCar.power = On and myCar.gear /= Parked and myCar.speed > SpeedRange'First,
     Post => myCar.speed < myCar'Old.speed;
   
   procedure ObjectHasGone with
     Global => (In_Out => myCar, Input => obstacles),
     Pre => myCar.sensors = Detected and myCar.power = On and obstacles = Absent,
     Post => myCar.sensors = Clear;
   
   --If sensors are activated and the car is moving - stop moving to avoid collision with object
   --Might be beneficial to mertge the detection function with this one - have precondtion require clear
   --and postcondition look for detected sensors (will need to set detected in the procedure)
   procedure SensorsActivated with
     Global => (In_Out => myCar),
     Pre => myCar.diagnosticMode = Off and myCar.sensors = Clear and myCar.speed >= 0,
     Post => myCar.speed = 0;
     --Post => myCar.gear = Parked;
   
   procedure CheckForObstacles with
     Global => (In_Out => myCar, Input => obstacles),
     Pre => myCar.power = On and myCar.diagnosticMode = Off and myCar.speed >= 0 and ((obstacles = Present and myCar.sensors = Clear) or (obstacles = Absent and myCar.sensors = Detected));
   
   --What is the 'any other operation' that this diagnostic mode renders the car incapable of doing - increasing/decreasing speed maybe?
   procedure EnableDiagnosticMode with
     Global => (In_Out => myCar),
     Pre => myCar.power = On and myCar.gear = Parked and myCar.diagnosticMode = Off,
     Post => myCar.diagnosticMode = On;
   
   procedure DisableDiagnosticMode with
     Global => (In_Out => myCar),
     Pre => myCar.power = On and myCar.gear = Parked and myCar.diagnosticMode = On,
     Post => myCar.diagnosticMode = Off;
   
   --Extension : Seatbelt warnings
   --Function to determine if passengers have their seatbelts plugged in
   --Will return true if there is a passenger present and does not have their seatbelt plugged in
   function PassengerWithoutSeatbelt return Boolean is
     (for some I in myCar.seats'Range =>
         (myCar.seats(I).passenger = Present and myCar.seats(I).seatbelt = Unplugged));
   
   --Main use is for getting the index of the warning lights array to add the warning light to
   function CountWarningLights return WarningsIndex with
     Global => (Input => myCar);
   
   function WarningLightIsOn (warning : Warnings) return Boolean is
     (for some I in myCar.wlights'Range =>
         (myCar.wlights(I) = warning));
   
   
   procedure TurnOnWarningLight (warning : Warnings) with
     Global => (In_Out => myCar),
     Pre => myCar.power = On and warning /= None and WarningLightIsOn(warning) = False and CountWarningLights < WarningsIndex'Last,
     Post => WarningLightIsOn(warning);
   
   procedure TurnOffWarningLight (warning : Warnings) with
     Global => (In_Out => myCar),
     Pre => myCar.power = On and WarningLightIsOn(warning) and warning /= None,
     Post => WarningLightIsOn(warning) = False;
   
   procedure EnableBatteryLight with
     Global => (In_Out => myCar),
     Pre => myCar.power = On and myCar.battery <= 15 and not WarningLightIsOn(BatteryLow) and CountWarningLights < WarningsIndex'Last,
     Post => WarningLightIsOn(BatteryLow);
   
   procedure EnableSeatbeltLight with
     Global => (In_Out => myCar),
     Pre => myCar.power = On and PassengerWithoutSeatbelt and not WarningLightIsOn(SeatbeltUnplugged) and CountWarningLights < WarningsIndex'Last,
     Post => WarningLightIsOn(SeatbeltUnplugged);
   
   function CheckForEmptySeats return Boolean is
     (for some I in myCar.seats'Range =>
        (myCar.seats(I).passenger = Absent));
   
   function CountPassengers return SeatIndex with
     Global => (Input => myCar);
   
   procedure AddPassenger with
     Global => (In_Out => myCar),
     Pre => CheckForEmptySeats and myCar.speed = 0,
     Post => (for some seat in myCar.seats'Range => myCar.seats(seat).passenger /= myCar.seats'Old(seat).passenger);

   procedure RemovePassenger(index : SeatIndex) with
     Global => (In_Out => myCar),
     Pre => CountPassengers > 0 and myCar.seats(index).passenger = Present and myCar.speed = 0,
     Post => myCar.seats(index).passenger = Absent;
   

end car;
