with car; use car;
with Ada.Text_IO; use Ada.Text_IO;

procedure Main is
   newLimit : SpeedRange := 0;
   input : String (1..1);
   input2 : String (1..2);
begin
   Put_Line("The car key is:");
   Put_Line(myCar.carKey'Image);
   Put_Line("The power is:");
   Put_Line(myCar.power'Image);
   Put_Line("The battery charge in the car is:");
   Put_Line(myCar.battery'Image);

   --  Put_Line("Battery warning light is:");
   --  EnablebatteryLight;
   --  if WarningLightIsOn(BatteryLow) then
   --     Put_Line("On");
   --  else
   --     Put_Line("Off");
   --  end if;
   --
   --  Put_Line("Seatbelt warning light is:");
   --  EnableSeatbeltLight;
   --  if WarningLightIsOn(SeatbeltUnplugged) then
   --     Put_Line("On");
   --  else
   --     Put_Line("Off");
   --  end if;

   Put_Line("Minimum battery required to run car:");
   Put_Line(minimumBatteryCharge'Image);

   Put_Line("Number of passengers is:");
   Put_Line(SeatIndex'Image(CountPassengers));

   Put_Line("*****************************************");
   Put_Line("Input action using number");
   Put_Line("1 - Insert/Remove key");
   Put_Line("2 - Turn on/off car power");
   Put_Line("3 - Set speed limit");
   Put_Line("4 - Gear change");
   Put_Line("5 - Increase Speed");
   Put_Line("6 - Decrease Speed");
   Put_Line("7 - Enable/Disable diagnostic mode");
   Put_Line("8 - Add passenger to car");
   Put_Line("9 - Remove specific passenger from car");
   Put_Line("'o' - Add/Remove obstacle");
   Put_Line("*****************************************");
   loop
      Get(input);

      --Insert/Remove key
      if input = "1" then
         Put_Line("********************************");
         if myCar.carKey = Absent then
            Put_Line("Key is now:");
            KeyInserted;
            Put_Line(myCar.carKey'Image);
         elsif myCar.carKey = Present then
            Put_Line("Key is now:");
            KeyRemoved;
            Put_Line(myCar.carKey'Image);
         end if;
         Put_Line("********************************");
      end if;

      --Turn on/off car power
      if input = "2" then
         Put_Line("********************************");
         if myCar.power = Off then
            Put_Line("Car power is now:");
            TurnOnCar;
            Put_Line(myCar.power'Image);

            Put_Line("Car is permitted to drive:");
            Put_Line(myCar.permitted'Image);

            if myCar.permitted = True then
               Put_Line("Speed limit is:");
               Put_Line(myCar.limit'Image);
               Put_Line("Battery warning light is:");

               EnablebatteryLight;
               if WarningLightIsOn(BatteryLow) then
                  Put_Line("On");
               else
                  Put_Line("Off");
               end if;

               Put_Line("Seatbelt warning light is:");
               EnableSeatbeltLight;
               if WarningLightIsOn(SeatbeltUnplugged) then
                  Put_Line("On");
               else
                  Put_Line("Off");
               end if;

            else
               Put_Line("Battery warning light is:");
               EnablebatteryLight;
               if WarningLightIsOn(BatteryLow) then
                  Put_Line("On");
               else
                  Put_Line("Off");
               end if;
            end if;
         else
            Put_Line("Car power is now:");
            TurnOffCar;
            Put_Line(myCar.power'Image);
         end if;
         Put_Line("********************************");
      end if;

      -- Set Speed limit [Required to be set so car can drive]
      -- Will have to input double digits (e.g. 04 for 4 speed)
      if input = "3" then
         Put_Line("********************************");
         Put_Line("Enter speed limit to obey");
         Get(input2);
         newLimit := SpeedRange'Value(input2);
         Put_Line("Speed limit is now:");
         SetSpeedLimit(newLimit);
         Put_Line(myCar.limit'Image);
         Put_Line("********************************");
      end if;

      -- Change Gear
      if input = "4" then
         Put_Line("********************************");
         Put_Line("Insert number for gear change");
         Put_Line("1 - Parked, 2 - Drive, 3 - Reverse");
         Get(input);
         Put_Line("********************************");
         if input = "1" then
            Put_Line("Car gear is now:");
            ChangeGear(Parked);
            Put_Line(myCar.gear'Image);
         elsif input = "2" then
            Put_Line("Car gear is now:");
            ChangeGear(Driving);
            Put_Line(myCar.gear'Image);
         else
            Put_Line("Car gear is now:");
            ChangeGear(Reversing);
            Put_Line(myCar.gear'Image);
         end if;
         Put_Line("********************************");
      end if;

      -- Increase speed
      if input = "5" then
         Put_Line("********************************");
         Put_Line("Checking for obstacles");
         CheckForObstacles;
         Put_Line(myCar.sensors'Image);

         if myCar.sensors = Detected then
            Put_Line("Car gear is now:");
            Put_Line(myCar.gear'Image);
         end if;

         Put_Line("Speed is now:");
         IncreaseSpeed;
         Put_Line(myCar.speed'Image);
         Put_Line("********************************");
      end if;

      -- Decrease speed
      if input = "6" then
         Put_Line("********************************");
         Put_Line("Checking for obstacles");
         CheckForObstacles;
         Put_Line(myCar.sensors'Image);

         if myCar.sensors = Detected then
            Put_Line("Car gear is now:");
            Put_Line(myCar.gear'Image);
         end if;


         Put_Line("Speed is now:");
         DecreaseSpeed;
         Put_Line(myCar.speed'Image);
         Put_Line("********************************");
      end if;

      -- Enable/Disable diagnostic mode
      if input = "7" then
         Put_Line("********************************");
         if myCar.diagnosticMode = Off then
            Put_Line("Diagnostic mode is:");
            EnableDiagnosticMode;
            Put_Line(myCar.diagnosticMode'Image);
         else
            Put_Line("Diagnostic mode is:");
            DisableDiagnosticMode;
            Put_Line(myCar.diagnosticMode'Image);
         end if;
         Put_Line("********************************");
      end if;

      -- Add passenger to car - passenger will be added to the first absent seat in the seats array
      if input = "8" then
         Put_Line("********************************");
         Put_Line("Adding passenger to car...");
         AddPassenger;
         Put_Line("Number of passengers is now:");
         Put_Line(SeatIndex'Image(CountPassengers));

         --If car is still off - expect light to be off
         Put_Line("Seatbelt warning light is:");
         EnableSeatbeltLight;
         if WarningLightIsOn(SeatbeltUnplugged) then
            Put_Line("On");
         else
            Put_Line("Off");
         end if;
         Put_Line("********************************");
      end if;

      -- Remove passenger from car [requires index of passenger to remove 0..5]
      if input = "9" then
         Put_Line("********************************");
         Put_Line("Insert index of passenger to remove from car");
         Get(input);
         Put_Line("Removing Passenger from car...");
         RemovePassenger(SeatIndex'Value(input));
         Put_Line("Number of passengers is now:");
         Put_Line(SeatIndex'Image(CountPassengers));

         Put_Line("Seatbelt warning light is:");
         EnableSeatbeltLight;
         if WarningLightIsOn(SeatbeltUnplugged) then
            Put_Line("On");
         else
            Put_Line("Off");
         end if;
         Put_Line("********************************");
      end if;

      --Adding/Removing obstacles to environment [for testing sensor functionality]
      if input = "o" then
         Put_Line("********************************");
         if obstacles = Absent then
            Put_Line("Adding obstacles");
            obstacles := Present;
         else
            Put_Line("Removing obstacles");
            obstacles := Absent;
         end if;
         Put_Line("********************************");
      end if;

   end loop;
end Main;
