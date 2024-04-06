{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options = {
    keyboardlayout = {
      akl = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Enable alt layout
        '';
      };
    };
  };
  config = {
    # force ansi as default
    services.kmscon.extraConfig = ''
      xkb-layout=us
    '';
    console.useXkbConfig = mkIf config.keyboardlayout.akl true;
    services.xserver.xkb.extraLayouts.psilocybin = mkIf config.keyboardlayout.akl {
      description = "psilocybin";
      languages = ["eng"];
      symbolsFile = ./psilocybin.xkb;
    };
    services.xserver.xkb.layout = mkIf config.keyboardlayout.akl "psilocybin";

    services.kanata = mkIf config.keyboardlayout.akl {
      enable = true;
      package = pkgs.rustPlatform.buildRustPackage {
        pname = "kanata";
        version = "1.6.0-git";
        src = pkgs.fetchFromGitHub {
          owner = "jtroo";
          repo = "kanata";
          rev = "5b51ee4eb64c2c2f065116c791c941b085deb23b";
          hash = "sha256-lwejLNyQGeBq1j9tttr1L3Zkc4actSAm4DoTCcGqB9U=";
        };
        cargoHash = "sha256-DdaKa8DGPAqRTpNQTxOSv8JX1SrD6n7tod6cf0Mu6yE=";
        buildFeatures = ["cmd"];
      };

      # workaround one-shot shift not working on keys with chord defined
      # https://github.com/jtroo/kanata/issues/900
      keyboards.psilocybin.extraDefCfg = ''
        rapid-event-delay 35
      '';
      keyboards.psilocybin.config = ''
        ;; extra jis keys for my laptop
        (defsrc
          grv  1     2    3    4    5    6     7    8    9    0    -    =    \
          tab  q     w    e    r    t    y     u    i    o    p    [    ]    bspc
          caps a     s    d    f    g    h     j    k    l    ;    '    ret
          lsft z     x    c    v    b    n     m    ,    .    /    rsft
          lctl lmet  lalt muhenkan spc henkan prtsc ralt rmet rctl
        )

        (deflayer psilocybin
          XX   XX    XX   XX   XX   XX   XX    XX   XX   XX   XX   XX   XX   XX
          XX   @x    @l   @c   @m   @z   XX    XX   @k   @f   @u   @o   @y   @.
          XX   @n    @r   @s   @t   @g   XX    XX   @b   @mgt @e   @a   @i
          XX   @j    @w   @p   @d   @q   XX    XX   @v   @h   @;   @'
          XX   @lmet lalt @lmet    @cspc @rmet @rmet @ral @rmet @ral
        )

        (deflayer psilocybin-tp
          XX   XX    XX   XX   XX   XX   XX    XX   XX   XX   XX   XX   XX   XX
          XX   x     l    c    m    z    XX    XX   k    f    u    o    y    .
          XX   n     r    s    t    g    XX    XX   b    @mgc e    a    i
          XX   j     w    p    d    q    XX    XX   v    h    ;    '
          _    _    _    _         spc  _    _    _    _    _
        )

        (deflayer nav
          _    _    _    _    _    _    _    _    _    _    _    _    _    _
          _    tab  XX   esc  @cls XX   XX   XX   @lng home up   end  del  _
          _    @sft @ctl @alt @cmd XX   XX   XX   @cbs left down rght bspc
          _    XX   XX   @cpy @pst XX   XX   XX   XX   ;    caps ret
          _    _    _    _         _    _    _    _    _    _
        )

        (deflayer sym
          _    _    _    _    _    _    _    _    _    _    _    _    _    _
          _    @<   [    @{   @lp  @~   XX   XX   @^   @rp  @}   ]    @>   `
          _    -    @*   =    @_   @$   XX   XX   @#   @cmd @alt @ctl @sft
          _    @+   @|   @at  /    @%   XX   XX   \    @&   @?   @!
          _    _    _    _         _    _    _    _    _    _
        )
        (deflayer num
          _    f1   f2   f3   f4   f5   XX   f6   f7   f8   f9   f10  f11  f12
          _    tab  XX   esc  XX   XX   XX   XX   /    7    8    9    @*   .
          _    @sft @ctl @alt @cmd XX   XX   XX   @-   4    5    6    0
          _    XX   XX   XX   XX   XX   XX   XX   @+   1    2    3
          _    _    _    _         _    _    _    _    _    _
        )

        (deflayer game
          grv  1     2    3    4    5    6     7    8    9    0    -    =    \
          tab  q     w    e    r    t    y     u    i    o    p    [    ]    C-bspc
          lctl a     s    d    f    g    h     j    k    l    ;    '    ret
          lsft z     x    c    v    b    n     m    ,    .    /    rsft
          _    _    _    _         spc  _    _    _    _    _
        )

        ;; all these complicated typing layer stuff are to disable chord while typing fast
        (deffakekeys
          to-base (layer-switch psilocybin)
          the (one-shot 5000 (layer-toggle the))
          the-r (one-shot 5000 (layer-toggle the-r))
          tho (one-shot 5000 (layer-toggle tho))
          they (one-shot 5000 (layer-toggle they))
        )

        (deflayermap (the)
          spc : (macro e spc) ;; <spc>*<spc> -> the<spc>
          ralt : (macro e m) ;; <spc>*<rpt> -> them
          ] : (macro e y) ;; <spc>*y -> they
          s : (on-press tap-vkey the-r) ;; <spc>*r -> the**(including r)
          a : (macro e n) ;; <spc>*n -> then
          d : (macro e s e) ;; <spc>*s -> these
          [ : (macro o (on-press tap-vkey tho)) ;; <spc>*o -> tho**
        )
        (deflayermap (the-r)
          spc : (macro e i r spc) ;; <spc>*r<spc> -> their<spc>
          ; : (macro e r e) ;; <spc>*re -> there
        )
        (deflayermap (tho)
          d : (macro s e) ;; <spc>*os  -> those
          . : (macro u g h) ;; <spc>*oh -> though
        )
        (deflayermap (they)
          s : (macro r e) ;; <spc>*y<rpt>r -> they're
          , : (macro v e) ;; <spc>*y<rpt>v -> they've
          w : (macro l l) ;; <spc>*y<rpt>l -> they'll
        )

        (defalias
          tp (multi
            (one-shot 35 (layer-toggle psilocybin-tp))
            (on-idle-fakekey to-base tap 30)
          )

          psi (layer-switch psilocybin)
          gam (layer-switch game)
          cbs C-bspc
          lng hngl ;; ime toggle
          cls A-f4
          cpy C-c
          pst C-v

          ;; one-shot modifiers
          sft (one-shot 2000 lsft)
          ctl (one-shot 2000 lctl)
          alt (one-shot 2000 lalt)
          cmd (one-shot 2000 lmet)

          magic (switch ;;🪄
            ;;;;;;;;;;;;;;;;;;;;;;;;
            ;; psilocybin
            ;;;sfbs 1.19%(shai)
            ((key-history m 1)) p break ;; 0.22%
            ;; sc 0.11%
            ;; cs 0.02% index middle
            ;; ue 0.13% slide
            ;; y' 0.02% sfb can be pressed with pinky thumb
            ((key-history y 1)) . break ;; 0.09% sfb
            ((key-history e 1)) u break ;; 0.01%
            ((and (key-history o 2) (key-history p 1))) (macro m e n t) break ;; 0.01% opment
            ;; remove script from the rule below
            ((and (key-history s 5)(key-history c 4)(key-history r 3) (key-history i 2) (key-history p 1))) t break
            ((and (key-history i 2) (key-history p 1))) (macro m e n t) break ;; 0.00% ipment
            ((key-history p 1)) t break ;; 0.08%
            ((key-history r 1)) l break ;; 0.07%
            ;; oa 0.07% is a slide
            ((key-history w 1)) s break ;; 0.04%
            ;; i' is easy to slide on wide mod 0.0%
            ((and (key-history a 2) (key-history d 1))) m break ;; dm 0.01% mostly consists of adm
            ((key-history d 1)) g break ;; 0.03%
            ;; tm index middle 0.03%
            ((key-history s 1)) w break ;; 0.03%
            ;; gt 0.01% easy index middle
            ((key-history l 1)) r break  ;; 0.01%
            ;; pd index middle 0.01%
            ;; e; can't be slided
            ;; dt 0.01% index middle
            ((and (key-history i 3) (key-history g 2) (key-history h 1))) (macro b o) break ;; hb 0.01%
            ;; 'a 0.01% can be pressed with pinky ring in this fat-i wide mod
            ;; total real sfbs 0.12%
            ;;((key-history t 1)) p break ;; not using this only 0.01%
            ;;;;;;;;;;;;;;;
            ;;th is the most common english bigram
            ((key-history spc 1)) (macro t h (on-press tap-vkey the)) break
            ;;tment most common tm words are tment
            ;; TODO Fix issue that macro gets interrupted before outputting t, putting delay doesn't fix
            ((and (key-history r 2) (key-history t 1))) (macro m e n t) break ;; rtment
            ((and (key-history n 2) (key-history t 1))) (macro m e n t) break ;; ntment
            ((and (key-history s 2) (key-history t 1))) (macro m e n t) break ;; stment
            ((and (key-history e 3) (key-history a 2) (key-history t 1))) (macro m e n t) break ;; eatment
            ((and (key-history u 3) (key-history i 2) (key-history t 1))) (macro m e n t) break ;; uitment
            ((and (key-history m 3) (key-history i 2) (key-history t 1))) (macro m e n t) break ;; mitment
            ;;ion 1.692%
            ((key-history i 1)) (macro o n) break

            ;;tch
            ((key-history t 1)) (macro c h) break

            ;; TODO somehow implement ious
          )
          mgc (chord jkesc *)
          mgt (multi @mgc @tp)

          repeat (switch
            ;; LSBs
            ((key-history k 1)) e break ;; 0.21% this really sucks, especially when typing "key". ka is fine
            ;;((key-history ))
            ;; they'
            ((and (key-history t 4) (key-history h 3) (key-history e 2) (key-history y 1))) (macro ' (on-press tap-vkey they)) break
            ;; ing
            ((key-history i 1)) (macro n g) break ;; i repeat is only 0.011%, compared to ing 3.302% just use left rpt key anyways
            ((key-history y 1)) (macro i n g) break ;; 0.04% sfb all common yis are ying
            ((and (key-history n 2) (key-history g 1))) (macro i n g) break ;; nging
            ((and (key-history o 2) (key-history w 1))) (macro i n g) break ;; owing
            ((and (key-history r 3) (key-history a 2) (key-history w 1))) (macro i n g) break ;; rawing
            ((and (key-history e 2) (key-history w 1))) (macro i n g) break ;; ewing
            () rpt break
          )
          ral @repeat

          cspc (tap-hold 200 300 spc lctl)
          lmet (chord thumb lm)
          rmet (chord thumb rm)
          nav (tap-hold-press 200 300 rpt (layer-toggle nav))
          sym (tap-hold-press 200 300 (fork , ' (lsft rsft)) (layer-toggle sym))
          num (layer-toggle num)

          ;; shifted keys
          { S-[
          } S-]
          lp S-9 ;; left parantheses (
          rp S-0 ;; right parantheses )
          ~ S-`
          ^ S-6
          * S-8
          _ S--
          $ S-4
          # S-3
          + S-=
          | S-\
          at S-2
          % S-5
          & S-7
          ? S-/
          ! S-1
          < S-,
          > S-.
          dq S-'

          x (multi x @tp)
          l (multi l @tp)
          b (multi b @tp)
          g (multi g @tp)
          v (multi v @tp)
          ' (multi ' @tp)
          f (multi f @tp)
          o (multi o @tp)
          u (multi u @tp)
          j (multi j @tp)
          - (multi - @tp)
          = (multi = @tp)
          n (multi n @tp)
          r (multi r @tp)
          s (multi s @tp)
          t (multi t @tp)
          d (multi d @tp)
          y (multi y @tp)
          h (multi h @tp)
          e (multi (chord jkesc e) @tp)
          a (multi a @tp)
          i (multi i @tp)
          , (multi (fork , ' (lsft rsft)) @tp)
          q (multi q @tp)
          c (multi c @tp)
          m (multi m @tp)
          w (multi w @tp)
          z (multi z @tp)
          p (multi p @tp)
          k (multi (chord backspace k) @tp)
          ; (multi (chord backspace ;) @tp)
          / (multi / @tp)
          . (multi . @tp)
        )

        (defchords thumb 2000
          (lm    ) @nav
          (   rm ) @sym
          (lm rm ) @num
        )

        (defchords jkesc 20
          (*    ) @magic
          (   e ) e
          (*  e ) esc
        )

        (defchords backspace 20
          (k   ) k
          (  ; ) ;
          (k ; ) bspc
        )

        (deflocalkeys-linux
          hngl 122 ;;ime on/off
        )

      '';
    };
  };
}
