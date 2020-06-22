library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DoorLock is
  port
  (
    Clock    : in   std_logic;
    Switches : in   std_logic_vector ( 7 downto 0);
    Buttons  : in   std_logic_vector ( 3 downto 0);
    LedsExt  : out  std_logic_vector ( 3 downto 0);
    Leds     : out  std_logic_vector ( 3 downto 0)
  );
end;

architecture Behavioral of DoorLock is

  signal   Code : std_logic_vector (5 downto 0);

  -- show result
  constant LedsExt_Success  : std_logic_vector ( 3 downto 0) := "1111";
  constant LedsExt_Failure  : std_logic_vector ( 3 downto 0) := "0001";
  signal   LedsExt_Buffer   : std_logic_vector ( 3 downto 0) := LedsExt_Failure;

  -- show state
  constant Leds_Set         : std_logic_vector ( 3 downto 0) := "0010";
  constant Leds_IdleSet     : std_logic_vector ( 3 downto 0) := "0100";
  constant Leds_IdleShow    : std_logic_vector ( 3 downto 0) := "1000";
  constant Leds_ShowSuccess : std_logic_vector ( 3 downto 0) := LedsExt_Success;
  constant Leds_ShowFailure : std_logic_vector ( 3 downto 0) := LedsExt_Failure;
  signal   Leds_Buffer      : std_logic_vector ( 3 downto 0) := "0000";

  -- debounce
  signal   ButtonsDeb       : std_logic_vector ( 3 downto 0) := "0000";

  component Debounce is
    port
    (
      Clock      : in  std_logic;                      --! clock
      Buttons    : in  std_logic_vector ( 3 downto 0); --! bouncing
      ButtonsDeb : out std_logic_vector ( 3 downto 0)  --! debounced
    );
  end component;

begin

  DoorLockDebounce : Debounce
  port map
  (
    Clock      => Clock,
    Buttons    => Buttons,
    ButtonsDeb => ButtonsDeb
  );

  process begin
    wait until rising_edge(Clock);

    if (Switches (7) = '1') then

      if (ButtonsDeb (0) = '1') then
        -- state: Set
        Leds_Buffer <= Leds_Set;
        Code        <= Switches (5 downto 0);
      else
        -- state: IdleSet
        Leds_Buffer <= Leds_IdleSet;
      end if;

      LedsExt_Buffer <= LedsExt_Failure;

    else

      if (ButtonsDeb (0) = '1') then
        if (Switches (5 downto 0) = Code) then
          -- state: ShowSuccess
          Leds_Buffer    <= Leds_ShowSuccess;
          LedsExt_Buffer <= LedsExt_Success;
        else
          -- state: ShowFailure
          Leds_Buffer    <= Leds_ShowFailure;
          LedsExt_Buffer <= LedsExt_Failure;
        end if;
      else
        -- state: IdleShow
        Leds_Buffer <= Leds_IdleShow;
      end if;

    end if;

  end process;

  LedsExt <= LedsExt_Buffer;
  Leds    <= Leds_Buffer;

end;
