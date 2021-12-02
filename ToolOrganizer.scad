moduleSize = 24;
moduleHeight = 100;
moduleWallThickness = 1.6;

topThickness = 25;

defaultHoleSize = moduleSize - moduleWallThickness * 2;

joinerHeight = moduleHeight/2;

function radiusFromInnerRadius(innerRadius, sides) =
    innerRadius/(cos(180/sides));

module innerRadiusCylinder(innerRadius, sides, height, center)
{
    cylinder(h=height, r=radiusFromInnerRadius(innerRadius, sides), center=center, $fn=sides);
}

module joinerShapes(tolerance, heightModifier, makeAngleCut = false)
{
    for (separation=[-1, 1])
    translate([0,separation * moduleSize * .3,moduleHeight/4])
    rotate(a=90, v=[0,0,1])
    difference()
    {
        union()
        {
            // our hexagon shape
            innerRadiusCylinder(moduleWallThickness - tolerance + .01, 6, moduleHeight/2, true);
            
            if (makeAngleCut)
            {
                translate([0,-moduleWallThickness/2,0])
                cube([radiusFromInnerRadius(moduleWallThickness - .15, 6), moduleWallThickness, moduleHeight/2 - 0], center=true);
            }
        }
        
        
        // cut the hexagon in half
        translate([0,(moduleWallThickness+2)/2 + .01,0])
            cube([moduleWallThickness*3, moduleWallThickness+2, moduleHeight], center=true);
        
        if (makeAngleCut)
        {
            // angle on the joiner for printing
            translate([0,moduleWallThickness/2,moduleHeight/4])
            rotate(a=45, v=[1,0,0])
            translate([0,-moduleWallThickness/2,moduleWallThickness/2])
            cube([moduleWallThickness*3, moduleWallThickness, moduleWallThickness*2], center=true);
        }
    }
    
    //innerRadiusCylinder(moduleWallThickness - .15, 6, moduleHeight/2, true);
}

module allJoinerCuts(unitDepth, unitWidth)
{
    for (y=[-((unitWidth-1) /2) * moduleSize:moduleSize:((unitWidth-1) /2) * moduleSize])
    translate([unitDepth/2* moduleSize - moduleWallThickness, y, 0])
        joinerShapes(0, -.2);
    
    for (x=[-((unitDepth-1) /2) * moduleSize:moduleSize:((unitDepth-1) /2) * moduleSize])
    translate([x, unitWidth/2* moduleSize - moduleWallThickness, 0])
    rotate(a=90, v=[0,0,1])
        joinerShapes(0, -.2);
}

module allJoiners(unitDepth, unitWidth)
{
    for (x=[-((unitDepth-1) /2) * moduleSize:moduleSize:((unitDepth-1) /2) * moduleSize])
    translate([x,-unitWidth/2* moduleSize - moduleWallThickness,0])
    rotate(a=90, v=[0,0,1])
        joinerShapes(.15, 0, true);
    
    for (y=[-((unitWidth-1) /2) * moduleSize:moduleSize:((unitWidth-1) /2) * moduleSize])
    translate([-unitDepth/2* moduleSize - moduleWallThickness,y,0])
    rotate(a=0, v=[0,0,1])
        joinerShapes(.15, 0, true);
}

module toolModule(unitDepth = 1, 
                  unitWidth = 1,
                  toolHoleDiameter = defaultHoleSize, 
                  toolHoleWidth = defaultHoleSize, 
                  toolHoleDepth = defaultHoleSize, 
                  toolHoleShape = "circle")
{
    union()
    {
        difference()
        {
            // the main module cube
            translate([0,0,moduleHeight/2])
            cube([moduleSize * unitDepth, moduleSize * unitWidth, moduleHeight], center=true);
            
            // cutout to create the module walls
            translate([0,0,moduleHeight/2])
            cube([moduleSize * unitDepth - moduleWallThickness * 2, 
                  moduleSize * unitWidth - moduleWallThickness * 2, 
                  moduleHeight + 1], center=true);
            
            allJoinerCuts(unitDepth,unitWidth);
            
            
        }
        
        difference()
        {

            // the top of the module
            translate([0,0,moduleHeight - topThickness/2])
            cube([moduleSize * unitDepth,
                  moduleSize * unitWidth,
                  topThickness], center=true);
            
            // the hole for the tool in the top
            if (toolHoleShape == "circle")
            {
                translate([0,0,moduleHeight - topThickness/2])
                cylinder(topThickness * 2, d = toolHoleDiameter, center=true, $fn=50);
            } else {
                translate([0,0,moduleHeight - topThickness/2])
                cube([toolHoleWidth,  toolHoleDepth, topThickness * 2], center=true);
            }
        }
            
        allJoiners(unitDepth, unitWidth);
        
        
    }
}



toolModule(1,1);