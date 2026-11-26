import 'package:flutter/material.dart';

/// Renkler referans ekran görüntülerinden örneklendi.
/// Açık ve karanlık tema aynı tasarım dilini paylaşır; [dark] uygulama
/// kökünde sistem/kullanıcı tercihine göre ayarlanır.
class C {
  static bool dark = false;
  static Color get page => dark ? const Color(0xFF0E0D12) : const Color(0xFFFBFAFD);
  static Color get ink => dark ? const Color(0xFFF2F0F7) : const Color(0xFF0B0A0F);
  static Color get label => dark ? const Color(0xFFA68BFF) : const Color(0xFF6D4ECF);
  static Color get grey => dark ? const Color(0xFF9D9AA8) : const Color(0xFF8A8890);
  static Color get greyLight => dark ? const Color(0xFF6E6B78) : const Color(0xFFB4B2B9);
  static const navTop = Color(0xFFBDA7FA);
  static const navBase = Color(0xFFAC91FA);
  static Color get accent => dark ? const Color(0xFF9479FF) : const Color(0xFF784CF9);
  static Color get panel => dark ? const Color(0xFF1C1B22) : const Color(0xFFF2F1F6);
  /// Beyaz yüzeyler (giriş kutuları, yuvarlak düğmeler)
  static Color get surface => dark ? const Color(0xFF1C1B22) : Colors.white;
  /// Siyah ana düğmeler
  static Color get button => dark ? const Color(0xFF34313F) : Colors.black;
  static Color get line => dark ? const Color(0xFF2A2931) : const Color(0xFFE9E8EE);
}

/// Malzeme paletleri: aydınlık, ana renk, koyu kenar, sedef ışığı, zemin gölgesi.
class Pal {
  final Color light, base, dark, sheen, shadow;
  final double sheenStrength;
  const Pal(this.light, this.base, this.dark, this.sheen, this.shadow,
      {this.sheenStrength = 0.5});

  static const purple = Pal(Color(0xFF6C51A8), Color(0xFF554090),
      Color(0xFF34245E), Color(0xFFC6B4F2), Color(0xFF9C86E8),
      sheenStrength: 0.42);
  static const purpleBand = Pal(Color(0xFF6A51A0), Color(0xFF4C3585),
      Color(0xFF3A2770), Color(0xFFB9A6F0), Color(0xFF9C86E8));
  static const red = Pal(Color(0xFFAE4E50), Color(0xFF8F2927),
      Color(0xFF560C10), Color(0xFFE79A97), Color(0xFFF2A9AE),
      sheenStrength: 0.35);
  static const gold = Pal(Color(0xFFC79A45), Color(0xFFA47A3A),
      Color(0xFF452D0E), Color(0xFFF2DDB1), Color(0xFFCBA05C));
  static const goldBand = Pal(Color(0xFFE6B53A), Color(0xFFD4A12E),
      Color(0xFFB0832A), Color(0xFFFFE9A8), Color(0xFFF4CE78),
      sheenStrength: 0.2);
  static const redBand = Pal(Color(0xFFDD5257), Color(0xFFC24448),
      Color(0xFFA83A40), Color(0xFFF59AA0), Color(0xFFF3A0A6),
      sheenStrength: 0.3);
  static const greenBand = Pal(Color(0xFF3CC683), Color(0xFF33B879),
      Color(0xFF289A62), Color(0xFF9CEBC3), Color(0xFF9DE6C1),
      sheenStrength: 0.3);
  static const green = Pal(Color(0xFF3F8463), Color(0xFF2F6A4F),
      Color(0xFF1E4535), Color(0xFFB4D6BF), Color(0xFF8FB89F));
  static const blue = Pal(Color(0xFF7487B5), Color(0xFF5D6F9F),
      Color(0xFF39466E), Color(0xFFB9C6E2), Color(0xFF9AA6C8));
  static const navy = Pal(Color(0xFF34497A), Color(0xFF26365A),
      Color(0xFF151F38), Color(0xFF7D90C0), Color(0xFF7D90C0));
  static const deepGreen = Pal(Color(0xFF3B7A55), Color(0xFF295A3C),
      Color(0xFF173826), Color(0xFF9BC9AB), Color(0xFF8FB89F));
  static const pink = Pal(Color(0xFFE7AFC6), Color(0xFFD99AB5),
      Color(0xFFB87896), Color(0xFFF7D9E6), Color(0xFFE8B6CB));
  static const lilac = Pal(Color(0xFF8E6BC9), Color(0xFF6C51B0),
      Color(0xFF4A378A), Color(0xFFCDBBF5), Color(0xFFB09CEB));
  static const ochre = Pal(Color(0xFFC79A4E), Color(0xFFA9803E),
      Color(0xFF805C26), Color(0xFFEBD3A0), Color(0xFFD4B07A));
  static const rose = Pal(Color(0xFFCB76A0), Color(0xFFAD517A),
      Color(0xFF6E2347), Color(0xFFEFB9D2), Color(0xFFF2B6D2));
  static const amber = Pal(Color(0xFFC79A55), Color(0xFFA8782E),
      Color(0xFF6A4410), Color(0xFFF0D8A5), Color(0xFFF2CE90));
  static const plum = Pal(Color(0xFFB0587F), Color(0xFF8E3561),
      Color(0xFF5E1B3F), Color(0xFFEBB2CC), Color(0xFFF5AFD0));
  static const charcoal = Pal(Color(0xFF26252B), Color(0xFF1D1C22),
      Color(0xFF141318), Color(0xFF3A3940), Color(0xFFB9B8BE),
      sheenStrength: 0.12);
}

class T {
  static const _sans = 'Figtree';
  static const _disp = 'InterTight';
  static const _mono = 'PlexMono';

  static TextStyle get sectionLabel => TextStyle(
      fontFamily: _sans,
      fontWeight: FontWeight.w800,
      fontSize: 9.4,
      letterSpacing: 0.15,
      color: C.label,
      height: 1.2);
  static TextStyle get display => TextStyle(
      fontFamily: _disp,
      fontWeight: FontWeight.w900,
      fontSize: 30.5,
      letterSpacing: -0.6,
      height: 1.1,
      color: C.ink);
  static TextStyle get monoTitle => TextStyle(
      fontFamily: _mono,
      fontWeight: FontWeight.w500,
      fontSize: 19.2,
      letterSpacing: 0.15,
      height: 1.2,
      color: C.ink);
  static TextStyle get monoTitleBold => TextStyle(
      fontFamily: _mono,
      fontWeight: FontWeight.w700,
      fontSize: 19.2,
      letterSpacing: 0.15,
      height: 1.2,
      color: C.ink);
  static TextStyle get monoCard => TextStyle(
      fontFamily: _mono,
      fontWeight: FontWeight.w500,
      fontSize: 14,
      letterSpacing: 0.2,
      color: Colors.white);
  static TextStyle get tabLabel => TextStyle(
      fontFamily: _mono,
      fontWeight: FontWeight.w700,
      fontSize: 10.5,
      letterSpacing: 2.2,
      color: Colors.white);
  static TextStyle get cardBody => TextStyle(
      fontFamily: _disp,
      fontWeight: FontWeight.w800,
      fontSize: 18.4,
      height: 1.38,
      letterSpacing: -0.05,
      color: Colors.white);
  static TextStyle get body => TextStyle(
      fontFamily: _sans,
      fontWeight: FontWeight.w400,
      fontSize: 12.8,
      height: 1.4,
      color: C.grey);
  static TextStyle get small => TextStyle(
      fontFamily: _sans,
      fontWeight: FontWeight.w400,
      fontSize: 9.4,
      color: Colors.white70);
  static TextStyle get bandKicker => TextStyle(
      fontFamily: _sans,
      fontWeight: FontWeight.w800,
      fontSize: 8.6,
      letterSpacing: 1.1,
      color: Color(0xCCFFFFFF));
  static TextStyle get bandTitle => TextStyle(
      fontFamily: _sans,
      fontWeight: FontWeight.w700,
      fontSize: 13.8,
      letterSpacing: -0.1,
      color: Colors.white);
  static TextStyle get bandSub => TextStyle(
      fontFamily: _sans,
      fontWeight: FontWeight.w400,
      fontSize: 10.6,
      color: Color(0xE6FFFFFF));
  static TextStyle get heading => TextStyle(
      fontFamily: _sans,
      fontWeight: FontWeight.w700,
      fontSize: 14.6,
      letterSpacing: -0.1,
      color: C.ink);
  static TextStyle get nav => TextStyle(
      fontFamily: _sans,
      fontWeight: FontWeight.w500,
      fontSize: 13.4,
      color: Colors.white);
}
