function kinectstream_Number = Kinect_Azure_Struct_Char2Number(kinectstream_Char)

            kinectstream_Number.wtime = kinectstream_Char.wtime;
            kinectstream_Number.ktime = kinectstream_Char.ktime;
            kinectstream_Number.name = kinectstream_Char.name;
            
            
            kinectstream_Number.Joint1 = kinectstream_Char.PELVIS;  
            kinectstream_Number.Joint2 = kinectstream_Char.SPINE_NAVAL;
            kinectstream_Number.Joint3 = kinectstream_Char.SPINE_CHEST;
            kinectstream_Number.Joint4 = kinectstream_Char.NECK;
            kinectstream_Number.Joint5 = kinectstream_Char.CLAVICLE_LEFT;
            kinectstream_Number.Joint6 = kinectstream_Char.SHOULDER_LEFT; 
            kinectstream_Number.Joint7 = kinectstream_Char.ELBOW_LEFT; 
            kinectstream_Number.Joint8 = kinectstream_Char.WRIST_LEFT;
            kinectstream_Number.Joint9 = kinectstream_Char.HAND_LEFT;
            kinectstream_Number.Joint10 = kinectstream_Char.HANDTIP_LEFT;
            kinectstream_Number.Joint11 = kinectstream_Char.THUMB_LEFT; 
            kinectstream_Number.Joint12 = kinectstream_Char.CLAVICLE_RIGHT; 
            kinectstream_Number.Joint13 = kinectstream_Char.SHOULDER_RIGHT; 
            kinectstream_Number.Joint14 = kinectstream_Char.ELBOW_RIGHT; 
            kinectstream_Number.Joint15 = kinectstream_Char.WRIST_RIGHT;
            kinectstream_Number.Joint16 = kinectstream_Char.HAND_RIGHT;
            kinectstream_Number.Joint17 = kinectstream_Char.HANDTIP_RIGHT;
            kinectstream_Number.Joint18 = kinectstream_Char.THUMB_RIGHT;
            kinectstream_Number.Joint19 = kinectstream_Char.HIP_LEFT;
            kinectstream_Number.Joint20 = kinectstream_Char.KNEE_LEFT;
            kinectstream_Number.Joint21 = kinectstream_Char.ANKLE_LEFT;          
            kinectstream_Number.Joint22 = kinectstream_Char.FOOT_LEFT; 
            kinectstream_Number.Joint23 = kinectstream_Char.HIP_RIGHT; 
            kinectstream_Number.Joint24 = kinectstream_Char.KNEE_RIGHT;
            kinectstream_Number.Joint25 = kinectstream_Char.ANKLE_RIGHT;
            kinectstream_Number.Joint26 = kinectstream_Char.FOOT_RIGHT;
            kinectstream_Number.Joint27 = kinectstream_Char.HEAD;
            kinectstream_Number.Joint28 = kinectstream_Char.NOSE;
            kinectstream_Number.Joint29 = kinectstream_Char.EYE_LEFT;
            kinectstream_Number.Joint30 = kinectstream_Char.EAR_LEFT;
            kinectstream_Number.Joint31 = kinectstream_Char.EYE_RIGHT;
            kinectstream_Number.Joint32 = kinectstream_Char.EAR_RIGHT;

end