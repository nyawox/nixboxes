# thanks to https://github.com/luccahuguet/yazelix/
{
  lib,
  config,
  inputs,
  username,
  ...
}:
with lib;
let
  cfg = config.modules.shell.zellij;
in
{
  options = {
    modules.shell.zellij = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableZshIntegration = false;
    };
    programs.nushell.shellAliases = {
      he = "zellij -s $'($env.PWD | path basename)-(random int)' --new-session-with-layout /home/${username}/.config/zellij/layouts/helix.kdl";
    };

    xdg.configFile = {
      "zellij/config.kdl".text =
        builtins.readFile ./zellij/config.kdl
        + ''
          theme "catppuccin-mocha"
          on_force_close "quit"
          simplified_ui true
          pane_frames true
          ui {
            pane_frames {
              hide_session_name true
              rounded_corners true
            }
          }
        '';

      "zellij/yazi/yazi.toml".text =
        # toml
        ''
          # yazi.toml

          [manager]
          ratio = [0, 4, 0]

          [opener]
          edit = [
            { run = 'nu ~/.config/zellij/yazi/open_file.nu "$1"', desc = "Open File in a new pane" },
          ]
        '';
      "zellij/yazi/theme.toml".source = inputs.catppuccin-yazi.outPath + "/themes/mocha.toml";
      "zellij/yazi/Catppuccin-mocha.tmTheme".source =
        inputs.catppuccin-bat.outPath + "/themes/Catppuccin Mocha.tmTheme";

      "zellij/yazi/init.lua".text =
        # lua
        ''
          function Status:render(area)
          	self.area = area

          	local line = ui.Line { self:percentage(), self:position() }
          	return {
          		ui.Paragraph(area, { line }):align(ui.Paragraph.CENTER),
          	}
          end
        '';

      "zellij/layouts/helix.kdl".source = ./zellij/helix.kdl;
      "zellij/layouts/helix.swap.kdl".source = ./zellij/helix.swap.kdl;

      "zellij/yazi/open_file.nu".text =
        # nu
        ''
          #!/usr/bin/env nu

          export def is_hx_running [list_clients_output: string] {
              let cmd = $list_clients_output | str trim | str downcase

              # Split the command into parts
              let parts = $cmd | split row " "

              # Check if any part ends with 'hx' or is 'hx'
              let has_hx = ($parts | any {|part| $part | str ends-with "/hx"})
              let is_hx = ($parts | any {|part| $part == "hx"})
              let has_or_is_hx = $has_hx or $is_hx

              # Find the position of 'hx' in the parts
              let hx_positions = ($parts | enumerate | where {|x| ($x.item == "hx" or ($x.item | str ends-with "/hx"))} | get index)

              # Check if 'hx' is the first part or right after a path
              let is_hx_at_start = if ($hx_positions | is-empty) {
                  false
              } else {
                  let hx_position = $hx_positions.0
                  $hx_position == 0 or ($hx_position > 0 and ($parts | get ($hx_position - 1) | str ends-with "/"))
              }

              let result = $has_or_is_hx and $is_hx_at_start

              # Debug information
              print $"input: list_clients_output = ($list_clients_output)"
              print $"treated input: cmd = ($cmd)"
              print $"  parts: ($parts)"
              print $"  has_hx: ($has_hx)"
              print $"  is_hx: ($is_hx)"
              print $"  has_or_is_hx: ($has_or_is_hx)"
              print $"  hx_positions: ($hx_positions)"
              print $"  is_hx_at_start: ($is_hx_at_start)"
              print $"  Final result: ($result)"
              print ""

              $result
          }



          def main [file_path: path] {
              # Move focus to the next pane
              zellij action focus-next-pane

              # Store the second line of the zellij clients list in a variable
              let list_clients_output = (zellij action list-clients | lines | get 1)

              # Parse the output to remove the first two words and extract the rest
              let running_command = $list_clients_output
                  | parse --regex '\w+\s+\w+\s+(?<rest>.*)'  # Use regex to match two words and capture the remaining text as 'rest'
                  | get rest  # Retrieve the captured 'rest' part, which is everything after the first two words
                  | to text

              # Check if the command running in the current pane is hx
              if (is_hx_running $running_command) {
                  # The current pane is running hx, use zellij actions to open the file
                  zellij action write 27
                  zellij action write-chars $":open \"($file_path)\""
                  zellij action write 13
              } else {
                  # The current pane is not running hx, so open hx in a new pane
                  zellij action new-pane
                  sleep 0.5sec

                  # Determine the working directory
                  let working_dir = if ($file_path | path exists) and ($file_path | path type) == "dir" {
                      $file_path
                  } else {
                      $file_path | path dirname
                  }

                  # Change to the working directory
                  zellij action write-chars $"cd ($working_dir)"
                  zellij action write 13
                  sleep 0.2sec

                  # Open Helix
                  zellij action write-chars $"hx ($file_path)"
                  sleep 0.1sec
                  zellij action write 13
                  sleep 0.1sec
              }
          }
        '';

      # might be good to have to debug?? idk
      "zellij/yazi/is_helix_running_test.nu".text =
        # nu
        ''
          #!/usr/bin/env nu

          # run this with `nu path/to/this/file`

          use std assert

          # Import the function to test
          use open_file.nu is_hx_running

          # Define test cases
          def test_cases [] {
              [
                  # Basic cases
                  ["hx", true, "Basic 'hx' command"],
                  ["HX", true, "Uppercase 'HX'"],
                  ["hx ", true, "hx with trailing space"],
                  [" hx", true, "hx with leading space"],

                  # Path cases
                  ["/hx", true, "hx at root"],
                  ["/usr/local/bin/hx", true, "Full path to hx"],
                  ["./hx", true, "Relative path to hx"],
                  ["../hx", true, "Parent directory hx"],
                  ["some/path/to/hx", true, "Nested path to hx"],

                  # With arguments
                  ["hx .", true, "hx with current directory"],
                  ["hx file.txt", true, "hx with file argument"],
                  ["hx -c theme:base16", true, "hx with flag"],
                  ["hx --help", true, "hx with long flag"],
                  ["/usr/local/bin/hx --version", true, "Full path hx with flag"],

                  # Negative cases
                  ["vim", false, "Different editor"],
                  ["echo hx", false, "hx in echo command"],
                  ["path/with/hx/in/middle", false, "hx in middle of path"],
                  ["hx_file", false, "hx as part of filename"],
              ]
          }

          # Run tests
          def run_tests [] {
              mut passed_count = 0
              let n_tests = test_cases | length

              for case in (test_cases) {
                  let input = $case.0
                  let expected = $case.1
                  let description = $case.2

                  print $"Testing: ($description)"
                  let result = (is_hx_running $input)
                  assert equal $result $expected $"Failed: ($description) - Expected ($expected), got ($result)"

                  # If the assertion passes, increment the counter and print the number of passed tests
                  $passed_count = $passed_count + 1
                  print $"Passed test #($passed_count) of ($n_tests): ($description)"
                  print ""
              }

              print $"Total tests passed: ($passed_count)"
          }

          # Main test runner
          def main [] {
              print "Running tests for is_hx_running function..."
              run_tests
              print "All tests completed!"
          }
        '';
    };
  };
}
