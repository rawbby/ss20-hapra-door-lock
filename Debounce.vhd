library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! debounce for buttons
entity Debounce is
  port
  (
    Clock      : in   std_logic;                      --! Taktsignal
    Buttons    : in   std_logic_vector ( 3 downto 0); --! prellende Eingaenge
    ButtonsDeb : out  std_logic_vector ( 3 downto 0)  --! entprellte Ausgaenge
  );
end;

architecture Behavioral of Debounce is

  constant Delay : unsigned (19 downto 0) := x"F4240"; -- 1000000
  signal   Count : unsigned (19 downto 0) := x"00000"; -- 0

  signal ButtonsDebBuffer : std_logic_vector (3 downto 0) := (others=>'0');
  signal ButtonsBuffer    : std_logic_vector (3 downto 0);

begin

  process begin

    wait until rising_edge(Clock);
    ButtonsBuffer <= Buttons;

    if (ButtonsBuffer = ButtonsDebBuffer) then
      Count <= x"00000";
    else
      Count <= Count + x"00001";
    end if;

    if (Count = Delay) then
      ButtonsDebBuffer <= ButtonsBuffer;
    end if;

  end process;

  ButtonsDeb <= ButtonsDebBuffer;

end;
