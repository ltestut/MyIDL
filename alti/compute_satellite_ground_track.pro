PRO compute_satellite_ground_track

;The orbit data is extracted from the following two-line orbital elements,
;1 26997U 01055A   13071.50420587 -.00000064  00000-0 -96377-5 0  6308
;2 26997 066.0384 113.1882 0008085 285.0697 221.3884 12.83923357526873
;Epoch (UTC):  12 March 2013 12:06:03
;Eccentricity:   0.0008085
;inclination:  66.0384°
;perigee height:   1319 km
;apogee height:  1332 km
;right ascension of ascending node:  113.1882°
;argument of perigee:  285.0697°
;revolutions per day:  12.83923357
;mean anomaly at epoch:  221.3884°
;orbit number at epoch:  52687

; 2 elements define the shape and size of the ellipse:
; ----------------------------------------------------
;eccentricity                :   0.0008224 ==> (e) : shape of the ellipse, describing how much it elongated compared to a circle. 
;semi major axis             :             ==> (a) : the sum of the periapsis and apoapsis distances divided by two
;perigee height  :  1331 km
;apogee height   :  1344 km

; 2 elements define the orientation of the orbital plane
;--------------------------------------------------------
;inclination                       :  66.0397°    ==> (i)     : vertical tilt of the ellipse with respect to the reference plane, measured at the ascending node (where the orbit passes upward through the reference plane)
;longitude of ascending node  (LAN): 117.8069°    ==> (Omega or psi) : horizontally orients the ascending node of the ellipse (where the orbit passes upward through the reference plane) with respect to the reference frame's vernal point.
; for a geocentric orbit, Earth's equatorial plane as the reference plane,and the First Point of Aries as the origin of longitude.
; In this case, the longitude is also called the *right ascension of the ascending node*, or RAAN.
; The angle is measured eastwards (or, as seen from the north, counterclockwise) from the First Point of Aries to the node.
; psi = l_o+(precessional-motion(or variation of the longitude of the ascending node in time)satellite-angular-speed - earth-angular-speed)(t-t_AN)
; t_AN is the crossing time at ascending node


; 2 more elements 
;-----------------
;argument of perigee         :  275.3535°   ==> (omega) : argument of periapsis defines the orientation of the ellipse (by the direction of the minor axis) in the orbital plane, as an angle measured from the ascending node to the semiminor axis.
;mean anomaly at epoch       :  154.4722°   ==> (v)     : mean anomaly at epoch (M_o\,\!) defines the position of the orbiting body along the ellipse at a specific time (the "epoch").

;revolutions per day:  12.80929361
;orbit number at epoch:  22104


;Two-Line Element (TLE) Format:
;
;1 AAAAAU YYLLLPPP BBBBB.BBBBBBBB .CCCCCCCC  DDDDD-D EEEEE-E F GGGGZ
;2 AAAAA HHH.HHHH III.IIII JJJJJJJ KKK.KKKK MMM.MMMM NN.NNNNNNNNRRRRRZ
;
;Example TLE for the International Space Station:
;ISS (ZARYA)
;1 25544U 98067A  00225.77853128 .00046489  00000-0 36183-3 0  9546
;2 25544  51.5750 210.9643 0011506 237.0618 183.7134 15.71169901 98813
;    [1] - Line #1 label
;    [2] - Line #2 label
;    [AAAAA] - Catalog Number assigned sequentially (5-digit integer from 1 to 99999)
;    [U] - Security Classification (U = Unclassified)
;    [YYLLLPPP] - International Designator (YY = 2-digit Launch Year; LLL = 3-digit Sequential Launch of the Year; PPP = up to 3 letter Sequential Piece ID for that launch)
;    [BBBBB.BBBBBBBB] - Epoch Time -- 2-digit year, followed by 3-digit sequential day of the year, followed by the time represented as the fractional portion of one day
;    [.CCCCCCCC] - ndot/2 Drag Parameter (rev/day2) -- one half the first time derivative of the mean motion.  This drag term is used by the SGP orbit propagator.
;    [DDDDD-D] - n double dot/6 Drag Parameter (rev/day3) -- one sixth the second time derivative of the mean motion. The "-D" is the tens exponent (10-D). This drag term is used by the SGP orbit propagator.
;    [EEEEE-E] - Bstar Drag Parameter (1/Earth Radii) -- Pseudo Ballistic Coefficient. The "-E" is the tens exponent (10-E). This drag term is used by the SGP4 orbit propagator.
;    [F] - Ephemeris Type -- 1-digit integer (zero value uses SGP or SGP4 as provided in the Project Spacetrack report.
;    [GGGG] - Element Set Number assigned sequentially (up to a 4-digit integer from 1 to 9999). This number recycles back to "1" on the update following element set number "9999."
;    [HHH.HHHH] - Orbital Inclination (from 0 to 180 degrees).
;    [III.IIII] - Right Ascension of the Ascending Node (from 0 to 360 degrees).
;    [JJJJJJJ] - Orbital Eccentricity -- there is an implied leading decimal point (between 0.0 and 1.0).
;    [KKK.KKKK] - Argument of Perigee (from 0 to 360 degrees).
;    [MMM.MMMM] - Mean Anomaly (from 0 to 360 degrees).
;    [NN.NNNNNNNN] - Mean Motion (revolutions per day).
;    [RRRRR] - Revolution Number (up to a 5-digit integer from 1 to 99999). This number recycles following revolution nymber 99999.
;    [Z] - Check Sum (1-digit integer). Both lines have a check sum that is computed from the sum of all integer characters on that line plus a "1" for each negative (-) sign on that line. The check sum is the modulo-10 (or ones digit) of the sum of the digits and negative signs. 

;Epoch (UTC):  12 March 2013 04:12:40
;:   0.0008224
;inclination:  66.0397°

ecc = 0.0008224               ;eccentricity
icl = rad(66.0397)            ;inclination
man = rad(221.3884)           ;mean anomaly
sma = (1331+1344)/2.          ;semi-major axis = arithemetic mean of periapsis(perigee) and apoapsis(apogee) distance
ran = rad(117.8069)           ;right ascension node or longitude of ascending node
chi = rad(275.3535+154.4722)  ;sum of argument of perigee and mean anomaly at epoch 

;Compute the eccentric anomaly and true anomaly from the mean anomly (given in TLE)
eca_arr    = FLTARR(4)
eca_arr[0] = man
FOR i=0,2 DO eca_arr[i+1] = eca_arr[i]-((eca_arr[i]-ecc*sin(eca_arr[i])-eca_arr[0]))/(1-cos(eca_arr[i]))
print,deg(eca_arr)
tra = 2*ATAN(SQRT((1+ecc)/(1-ecc))*TAN(eca_arr[3]/2.))
print,deg(tra)+360.

orb_pos=ran+tra
print,deg(orb_pos)

 
;
;The radius (distance from the focus of attraction and the orbiting body) is related to the true anomaly by the formula
radius=(sma*(1-ecc*ecc))/(1+ecc*cos(v))
orbit=[[cos(ran)*cos(chi)-sin(ran)*sin(chi)*cos(icl)],[sin(ran)*cos(chi)+cos(ran)*sin(chi)*cos(icl)],[sin(chi)*cos(icl)]]

END