function f = Fmin(joints_position_model, joints_position_origin)

weight.SpineBase = 1;      %1
weight.Head = 0.2;         %2
weight.ShoulderLeft = 1;   %3
weight.ElbowLeft = 0.6;    %4
weight.WristLeft = 0.5;    %5
weight.HandLeft = 0;       %6
weight.ShoulderRight = 1;  %7
weight.ElbowRight = 0.6;   %8
weight.WristRight = 0.5;   %9
weight.HandRight = 0;      %10
weight.HipLeft = 1;        %11
weight.KneeLeft = 1;       %12
weight.AnkleLeft = 1;      %13
weight.FootLeft = 0.2;     %14
weight.HipRight = 1;       %15
weight.KneeRight = 1;      %16
weight.AnkleRight = 1;     %17
weight.FootRight = 0.2;    %18
weight.SpineShoulder = 1;  %19

weights = [weight.SpineBase,weight.Head,weight.ShoulderLeft,weight.ElbowLeft,...
weight.WristLeft,weight.HandLeft,weight.ShoulderRight,weight.ElbowRight,...;
weight.WristRight,weight.HandRight,weight.HipLeft,weight.KneeLeft,...
weight.AnkleLeft,weight.FootLeft,weight.HipRight,weight.KneeRight,...
weight.AnkleRight,weight.FootRight,weight.SpineShoulder];

f = sum(sum(weights*(joints_position_origin - joints_position_model).^2,2));
end

