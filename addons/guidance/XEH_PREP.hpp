LOG("prep");
PREP(cycleAttackProfileKeyDown);
PREP(keyDown);

PREP(checkFuze);
PREP(checkLos);
PREP(checkSeekerAngle);

PREP(onFired);
PREP(onIncomingMissile);

PREP(guidancePFH);
PREP(runAttackProfile); 
PREP(runSeekerSearch);

PREP(extractInfo);

// Attack Profiles
PREP(attackProfile_AAM);
PREP(attackProfile_AGM);
PREP(attackProfile_FGM);
PREP(attackProfile_FIM);
PREP(attackProfile_GBU);
PREP(attackProfile_LIN);
PREP(attackProfile_INDIRECT);
PREP(attackProfile_SSBM);

// Seeker search functions
PREP(seekerType_EO);
PREP(seekerType_GPS);
PREP(seekerType_IR);
PREP(seekerType_PRH);
PREP(seekerType_SACLOS);
PREP(seekerType_PLOS);
PREP(seekerType_MCLOS);
PREP(seekerType_SALH);

PREP(camera_init);
PREP(camera_update);
PREP(camera_updateTargetingGate);
PREP(camera_switchTo);
PREP(camera_switchAway);
PREP(camera_destroy);
PREP(camera_cycleViewMode);
PREP(camera_setViewMode);
PREP(camera_changeZoom);
PREP(camera_setZoom);
PREP(camera_handleKeyPress);
PREP(camera_userInCamera);
PREP(camera_getCameraNamespaceFromProjectile);
