{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  # workaround one-shot shift not working on keys with chord defined
  # https://github.com/jtroo/kanata/issues/900
  defCfg = ''
    rapid-event-delay 35
  '';
  ansi = ''
    (defsrc
      esc  1     2    3    4    5    6     7    8    9    0    -    =    \    grv
      tab  q     w    e    r    t    y     u    i    o    p    [    ]    bspc
      lctl a     s    d    f    g    h     j    k    l    ;    '    ret
      lsft z     x    c    v    b    n     m    ,    .    /    rsft
      caps lmet                 spc             ralt rmet rctl
    )

    (deflayer psilocybin
      XX   XX    XX   XX   XX   XX   XX    XX   XX   XX   XX   XX   XX   XX   XX
      XX   @x    @l   @c   @m   @k   XX    XX   @z   @f   @u   @o   @y   @.
      @lrp @n    @r   @s   @t   @g   XX    XX   @b   @mgt @e   @a   @i
      XX   @j    @w   @p   @d   @q   XX    XX   @v   @h   @;   @'
      XX   @lmet               @spc            @ral @rmet @ral
    )

    (deflayer psilocybin-tp
      _    _    _    _    _    _    _    _    _    _    _    _    _    _    _
      _    x     l    c    m    k    XX    XX   z    f    u    o    y    .
      _    n     r    s    t    g    XX    XX   b    @mgc e    a    i
      _    j     w    p    d    q    XX    XX   v    h    ;    '
      _    _                    _               _    _    _
    )

    (deflayer nav
      _    _    _    _    _    _    _    _    _    _    _    _    _    _    _
      _    ⭾    XX   esc  @cls XX   XX   XX   @lng ⇤    ▲    ⇥    ⌦    _
      _    @sft @ctl @alt @cmd XX   XX   XX   @cbs ◀    ▼    ▶    ⌫
      _    XX   prnt @cpy @pst XX   XX   XX   XX   ;    ⇪    ⏎
      _    _                   _              _    _    _
    )

    (deflayer sym
      _    _    _    _    _    _    _    _    _    _    _    _    _    _    _
      _    @<   [    @{   @lp  @~   XX   XX   @^   @rp  @}   ]    @>   `
      _    -    @*   =    @_   @$   XX   XX   @#   @cmd @alt @ctl @sft
      _    @:   @dq  @at  /    @|   XX   XX   \    @&   @?   @!
      _    _                   _              _    _    _
    )
    (deflayer num
      _    f1   f2   f3   f4   f5   XX   XX   f6   f7   f8   f9   f10  f11  f12
      _    ⭾    XX   esc  XX   XX   XX   XX   ⁄    7    8    9    🔢∗  .
      _    @sft @ctl @alt @cmd XX   XX   XX   -    4    5    6    0
      _    XX   XX   XX   @%   XX   XX   XX   🔢₊  1    2    3
      _    _                   _              _    _    _
    )

    (deflayer game
      esc  1     2    3    4    5    6    7    8    9    0    -    =    /    grv
      tab  q     w    e    r    t    y    u    i    o    p    [    ]    @cbs
      lctl a     s    d    f    g    h    j    k    l    ;    '    ret
      lsft z     x    c    v    b    n    m    ,    .    /    rsft
      _    _                    _              _    _    _
    )
  '';
  jis = ''
    (defsrc
      grv  1    2    3    4    5    6    7    8    9    0    -    =    ¥   bspc
      tab  q    w    e    r    t    y    u    i    o    p    [    ]    ret
      caps a    s    d    f    g    h    j    k    l    ;    '    \
      lsft z    x    c    v    b    n    m    ,    .    /    ro   rsft
      lctl lmet lalt mhnk      spc       henk  kana ralt prtsc rctl
    )

    (deflayer psilocybin
      XX   XX    XX   XX   XX   XX   XX    XX   XX   XX   XX   XX   XX   XX  XX
      XX   @x    @l   @c   @m   @k   XX    XX   @z   @f   @u   @o   @y   @.
      @lrp @n    @r   @s   @t   @g   XX    XX   @b   @mgt @e   @a   @i
      XX   @j    @w   @p   @d   @q   XX    XX   @v   @h   @;   @'   @'
      XX   XX    lalt @lmet     @spc       XX    XX  XX   @rmet @ral
    )

    (deflayer psilocybin-tp
      _    _     _    _    _    _    _     _    _    _    _    _    _    _    _
      _    x     l    c    m    k    XX    XX   z    f    u    o    y    .
      _    n     r    s    t    g    XX    XX   b    @mgc e    a    i
      _    j     w    p    d    q    XX    XX   v    h    ;    '    '
      _    _     _    _         _          _     _    _     _   _
    )

    (deflayer nav
      _    _    _    _    _    _    _    _    _    _    _    _    _    _    _
      _    ⭾    XX   esc  @cls XX   XX   XX   @lng ⇤    ▲    ⇥    ⌦    _
      _    @sft @ctl @alt @cmd XX   XX   XX   @cbs ◀    ▼    ▶    ⌫
      _    XX   prnt @cpy @pst XX   XX   XX   XX   ;    ⇪    ⏎    ⏎
      _    _     _    _         _          _     _    _     _   _
    )

    (deflayer sym
      _    _    _    _    _    _    _    _    _    _    _    _    _    _    _
      _    @<   [    @{   @lp  @~   XX   XX   @^   @rp  @}   ]    @>   `
      _    -    @*   =    @_   @$   XX   XX   @#   @cmd @alt @ctl @sft
      _    @:   @dq  @at  /    @|   XX   XX   \    @&   @?   @!   @!
      _    _     _    _         _          _     _    _     _   _
    )
    (deflayer num
      _    f1   f2   f3   f4   f5   XX   XX   f6   f7   f8   f9   f10  f11  f12
      _    ⭾    XX   esc  XX   XX   XX   XX   ⁄    7    8    9    🔢∗  .
      _    @sft @ctl @alt @cmd XX   XX   XX   -    4    5    6    0
      _    XX   XX   XX   @%   XX   XX   XX   🔢₊  1    2    3    3
      _    _     _    _         _          _     _    _     _   _
    )

    (deflayer game
      esc  1     2    3    4    5    6    7    8    9    0    -    =    /    grv
      tab  q     w    e    r    t    y    u    i    o    p    [    ]    @cbs
      lctl a     s    d    f    g    h    j    k    l    ;    '    ret
      lsft z     x    c    v    b    n    m    ,    .    /    rsft rsft
      _    _     _    _         _          _     _    _     _   _
    )

  '';
  psilocybin = ''
    ;; typing layer are used to disable chord while typing fast
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
      , : (macro v e) ;; <spc>*y<rpt>v -> they've ;; this is the 4th hardest word in this layout
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
        ;;;sfbs 0.82%
        ((key-history m 1)) p break ;; 0.16% sfb
        ;; sc 0.09% sfb index middle
        ;; cs 0.02% sfb index middle
        ;; ue 0.08% sfb slide
        ;; y' scissor can be copped with pinky thumb
        ((key-history y 1)) . break ;; 0.06% sfb
        ((and (key-history a 5) (key-history m 4) (key-history a 3) (key-history t 2) (key-history e 1))) u break ;; te* -> ted unless amateur
        ((and (key-history m 2) (key-history a 1))) t break ;; ma* -> mat sfs
        ((and (key-history t 2) (key-history e 1))) d break ;; te* -> ted sfs
        ((key-history e 1)) u break ;; 0.01% sfb
        ;; most pms which is 0.01% sfb are pment, use left rpt key for other pms
        ((and (key-history l 3)(key-history o 2) (key-history p 1))) (macro m e n t) break ;; 0.01% opment
        ((and (key-history o 3)(key-history o 2) (key-history p 1))) (macro m e n t) break ;; 0.01% opment
        ;; remove script from the rule below
        ((and (key-history s 5)(key-history c 4)(key-history r 3) (key-history i 2) (key-history p 1))) t break
        ((and (key-history i 2) (key-history p 1))) (macro m e n t) break ;; 0.00% ipment
        ((key-history p 1)) t break ;; 0.05% sfb
        ((key-history r 1)) l break ;; 0.05% sfb
        ;; oa 0.05% sfb is a slide
        ((key-history w 1)) s break ;; 0.03% sfb
        ;; i' is easy to slide or pinky ring on wide mod
        ((and (key-history g 3) (key-history a 2) (key-history d 1))) g break ;; gadget
        ((and (key-history b 3) (key-history a 2) (key-history d 1))) g break ;; badge
        ((and (key-history a 2) (key-history d 1))) m break ;; dm 0.01% sfb mostly consists of adm, otherwise cope with index middle
        ((key-history d 1)) g break ;; 0.02% sfb
        ;; tm index middle 0.02% sfb
        ((key-history s 1)) w break ;; 0.02% sfb
        ;; gt 0.01% sfb easy index middle
        ((key-history l 1)) r break ;; 0.01% sfb
        ((key-history a 1)) o break ;; 0.00% sfb but still, cause it's not altable
        ;; pd middle index 0.01% sfb
        ;; e; can't be slided
        ;; dt 0.00% sfb index middle
        ;; maybe bv(obvious) which is a rare sfb can be slided
        ((and (key-history i 3) (key-history g 2) (key-history h 1))) (macro b o) break ;; hb 0.01% sfb is mostly neighbo
        ;; 'a 0.01% sfb and a' 0.01% sfb can be pressed with pinky ring in this fat-i wide mod
        ;; total real sfbs 0.05% if the math is correct
        ;;;;;;;;;;;;;;;
        ;;th is the most common english bigram
        ((or (key-history spc 1) (key-history tab 1) (key-history ret 1))) (macro t h (on-press tap-vkey the)) break
        ;;tment most common tm words are tment
        ;; Put delay to avoid macro being interrupted when the key isn't released. key-release didn't work
        ((and (key-history r 2) (key-history t 1))) (macro m e n 50 t) break ;; rtment
        ((and (key-history n 2) (key-history t 1))) (macro m e n 50 t) break ;; ntment
        ((and (key-history s 2) (key-history t 1))) (macro m e n 50 t) break ;; stment
        ((and (key-history f 2) (key-history t 1))) (macro m e n 50 t) break ;; ftment
        ((and (key-history e 3) (key-history a 2) (key-history t 1))) (macro m e n 50 t) break ;; eatment
        ((and (key-history u 3) (key-history i 2) (key-history t 1))) (macro m e n 50 t) break ;; uitment
        ((and (key-history m 3) (key-history i 2) (key-history t 1))) (macro m e n 50 t) break ;; mitment
        ;;ion 1.692%
        ((key-history i 1)) (macro o n) break

        ;;tch
        ((key-history t 1)) (macro c h) break
        ;; ver 1.003%
        ((key-history v 1)) (macro e r) break ;; press with index middle, otherwise it just makes another sfb
        ;; just 0.232%, still most frequent ngram that starts with j
        ((key-history j 1)) (macro u s t) break

        ;; ght 0.317% common sfs
        ((key-history g 1)) (macro h t) break
        ;; nts 0.13% common redirect
        ((key-history n 1)) (macro t s) break
        ;; put 0.04% sfs
        ((and (key-history p 2) (key-history u 1))) t break
        ;; top 0.03%
        ((and (key-history t 2) (key-history o 1))) p break

        ;; TODO somehow implement ious
      )
      mgc (chord jkesc *)
      mgt (multi @mgc @tp)

      repeat (switch
        ;; Use this left repeat key mostly when repeating left hand bigram like ll
        ;; Also key(feels like a roll) ying ing ngin owing rawing ewing
        ;; LSBs 1.75%
        ;; ve 0.59% comfy
        ;; be 0.35% fine
        ;; ev 0.17% comfy
        ;; bu 0.15% comfy
        ;; ck 0.13% comfy
        ;; ds 0.08% comfy
        ;; ub 0.04% comfy
        ;; gs 0.04% fine
        ;; eb 0.03% fine
        ;; ek 0.02% not bad
        ;; sd 0.01% comfy
        ;; dw 0.01% not bad
        ;; dc 0.01% not bad
        ;; they'
        ((and (key-history t 4) (key-history h 3) (key-history e 2) (key-history y 1))) (macro ' (on-press tap-vkey they)) break
        ;; ing
        ((key-history i 1)) (macro n g) break ;; i repeat is only 0.011%, compared to ing 3.302% just use left rpt key anyways
        ((key-history y 1)) (macro i n g) break ;; 0.03% sfb all common yis are ying
        ((and (key-history n 2) (key-history g 1))) (macro i n 50 g) break ;; nging
        ((and (key-history n 2) (key-history d 1))) (macro i n g) break ;; nding
        ((and (key-history o 2) (key-history w 1))) (macro i n g) break ;; owing
        ((and (key-history r 3) (key-history a 2) (key-history w 1))) (macro i n g) break ;; rawing
        ((and (key-history r 3) (key-history o 2) (key-history w 1))) (macro i n g) break ;; rowing
        ((and (key-history e 2) (key-history w 1))) (macro i n g) break ;; ewing
        ((key-history v 1)) (macro i n g) break ;; ving
        ((key-history h 1)) (macro a v) break ;; 0.194% sfs
        ((key-history a 1)) (macro n d) break ;; 3.639% common ngram
        () rpt break
        ;; Currently 7.168% usage + 6.046% of repeats, total 13.214
        ;; Space bar is like 20% usage
      )

      ral @repeat

      lrp (switch
        ;; use this repeat key when typing most ke(s), which is uncomfortable with right repeat key
        ;; also use for common right hand repeat bigrams like ff, ee(unless next letter is n?)
        ;; and uncommon bigrams like ii(wii mii)
        ((and (key-history i 2) (key-history p 1))) (macro t) break
        ((key-history p 1)) m break ;; 0.01% sfb, use right repeat key for pp, magic key for pment
        ((key-history k 1)) (macro i n g) break ;; 0.305% the rule is, put on the opposite hand repeat key
        ((key-history t 1)) p break ;; 0.01% sfb
        ((key-history w 1)) (macro a s) break ;; 0.192% sfs
        ;; get 0.134% common sfs
        ((key-history g 1)) (macro e t) break
        () rpt break ;; 1.567%
        ;; Currently 2.56% usage + 1.567% of repeats, total 4.127%
        ;; keep this as low as possible
      )

      spc (tap-hold 200 300 spc lctl)
      lmet (chord thumb lm)
      rmet (chord thumb rm)
      nav (layer-toggle nav)
      ;;nav (tap-hold-press 200 300 r (layer-toggle nav)) thumb-r is just a concept, still needs to fix delay
      sym (tap-hold-press 200 300 , (layer-toggle sym))
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
      | S-\
      at S-2
      % S-5
      & S-7
      ? S-/
      ! S-1
      < S-,
      > S-.
      dq S-'
      : S-;

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
      k (multi k @tp)
      h (multi (chord backspace h) @tp)
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
      (h   ) h
      (  ; ) ;
      (h ; ) bspc
    )

    (deflocalkeys-linux
      hngl 122 ;;ime on/off
    )
  '';
in {
  options = {
    keyboardlayout = {
      akl = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Enable alt layout
        '';
      };
      ansi = mkOption {
        type = types.bool;
        default =
          if config.keyboardlayout.jis
          then false
          else true;
      };
      jis = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = {
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
        meta = with lib; {
          description = "A tool to improve keyboard comfort and usability with advanced customization";
          homepage = "https://github.com/jtroo/kanata";
          license = licenses.lgpl3Only;
          maintainers = with maintainers; [bmanuel linj];
          platforms = platforms.unix;
          mainProgram = "kanata";
        };
      };

      keyboards.psilocybin = mkIf config.keyboardlayout.ansi {
        extraDefCfg = defCfg;
        config = ansi + psilocybin;
      };
      keyboards.psilocybinjis = mkIf config.keyboardlayout.jis {
        extraDefCfg = defCfg;
        config = jis + psilocybin;
      };
    };
  };
}
