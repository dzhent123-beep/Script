--[[ luxxs v4.2 | by DrHub | MM2 ]]
local TweenService=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Lighting=game:GetService("Lighting")
local HttpService=game:GetService("HttpService")
local Workspace=game:GetService("Workspace")
local VU=game:GetService("VirtualUser")
local StatsSvc=game:GetService("Stats")
local LP=Players.LocalPlayer
local mouse=LP:GetMouse()

local FOLDER="luxxs"
local VALID_KEYS={["best"]=true,["drhub_nurhub_best"]=true}
local hasFS=type(writefile)=="function" and type(readfile)=="function" and type(isfile)=="function"
local function ensureFolder() if type(makefolder)=="function" and type(isfolder)=="function" and not isfolder(FOLDER) then pcall(makefolder,FOLDER) end end

-- ===== THEME =====
local ACCENTS={Green=Color3.fromRGB(86,255,126),Lime=Color3.fromRGB(196,255,61),Ice=Color3.fromRGB(110,214,255),Violet=Color3.fromRGB(158,110,255),Gold=Color3.fromRGB(255,196,70),Rose=Color3.fromRGB(255,96,160),Coral=Color3.fromRGB(255,104,84)}
local ACCENT_NAMES={"Green","Lime","Ice","Violet","Gold","Rose","Coral"}
local ACC_NAME="Green"
if hasFS then pcall(function() local p=FOLDER.."/accent.txt"; if isfile(p) then local n=readfile(p); if ACCENTS[n] then ACC_NAME=n end end end) end
local ACC=ACCENTS[ACC_NAME]

local C={bg=Color3.fromRGB(10,12,11),panel=Color3.fromRGB(15,18,16),row=Color3.fromRGB(24,29,26),line=Color3.fromRGB(38,46,41),off=Color3.fromRGB(56,64,60),text=Color3.fromRGB(232,238,233),dim=Color3.fromRGB(120,134,126),red=Color3.fromRGB(255,84,84)}
local WHITE=Color3.fromRGB(255,255,255)
local BODY_GRAY=Color3.fromRGB(196,196,206)
local F_HEAD,F_BODY,F_MONO,F_SEC=Enum.Font.Michroma,Enum.Font.SourceSansSemibold,Enum.Font.RobotoMono,Enum.Font.Oswald
local ROLE_COLORS={Murderer=Color3.fromRGB(255,60,60),Sheriff=Color3.fromRGB(70,130,255),Innocent=Color3.fromRGB(70,230,110)}
local ROLE_NAMES={"Murderer","Sheriff","Innocent"}

local G={alpha=0,size=1}
local themed,bgReg={},{}
local function T(o,p,fn) themed[#themed+1]={o,p,fn}; o[p]=fn and fn(ACC) or ACC end
local function setAccent(c) ACC=c; for _,t in ipairs(themed) do pcall(function() t[1][t[2]]=t[3] and t[3](ACC) or ACC end) end end
local function BG(o,base) bgReg[#bgReg+1]={o,base}; o.BackgroundTransparency=math.clamp(base+G.alpha,0,1); return o end
local function applyAlpha() for _,r in ipairs(bgReg) do if r[1].Parent then r[1].BackgroundTransparency=math.clamp(r[2]+G.alpha,0,1) end end end

local connections={} local function track(c) connections[#connections+1]=c; return c end
local function tween(o,ti,p,s,d) local tw=TweenService:Create(o,TweenInfo.new(ti,s or Enum.EasingStyle.Quint,d or Enum.EasingDirection.Out),p); tw:Play(); return tw end
local function new(cls,props) local o=Instance.new(cls); for k,v in pairs(props) do if k~="Parent" then o[k]=v end end; o.Parent=props.Parent; return o end
local function corner(o,r) return new("UICorner",{CornerRadius=UDim.new(0,r),Parent=o}) end
local function stroke(o,col,th,tr) return new("UIStroke",{Color=col,Thickness=th or 1,Transparency=tr or 0,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=o}) end
local function gradient(f,rot,seq,tseq) local g=new("UIGradient",{Rotation=rot or 0,Parent=f}); if seq then g.Color=seq end; if tseq then g.Transparency=tseq end; return g end
local function cornerTick(parent,x,y,dx,dy,len,z)
    local h=new("Frame",{BorderSizePixel=0,Size=UDim2.fromOffset(len,1),Position=UDim2.fromOffset(dx>0 and x or x-len,dy>0 and y or y-1),ZIndex=z or 5,Parent=parent}); T(h,"BackgroundColor3")
    local v=new("Frame",{BorderSizePixel=0,Size=UDim2.fromOffset(1,len),Position=UDim2.fromOffset(dx>0 and x or x-1,dy>0 and y or y-len),ZIndex=z or 5,Parent=parent}); T(v,"BackgroundColor3")
end
local function setLine(f,x1,y1,x2,y2,th,col)
    local dx,dy=x2-x1,y2-y1
    f.Size=UDim2.fromOffset(math.sqrt(dx*dx+dy*dy),th); f.Position=UDim2.fromOffset((x1+x2)/2,(y1+y2)/2); f.Rotation=math.deg(math.atan2(dy,dx))
    if col then f.BackgroundColor3=col end
    f.Visible=true
end

-- colors are stored as {h,s,v,rb} tables so they save to JSON and support shades
local function hsvOf(c) local h,s,v=c:ToHSV(); return {h=h,s=s,v=v,rb=false} end
local function colorOf(c,t,off)
    if type(c)~="table" then return ACC end
    if c.rb then return Color3.fromHSV(((t or os.clock())*0.2+(off or 0))%1,math.max(c.s,0.5),math.max(c.v,0.6)) end
    return Color3.fromHSV(c.h,c.s,c.v)
end
local function copyColor(c) return {h=c.h,s=c.s,v=c.v,rb=c.rb and true or false} end

local Flags,Setters,Defaults={},{},{}
local function register(k,d,s) Flags[k]=d; Defaults[k]=d; Setters[k]=s end

-- ===== GUI ROOTS =====
local okP,parentGui=pcall(function() return (gethui and gethui()) or game:GetService("CoreGui") end)
if not okP or not parentGui then parentGui=LP:WaitForChild("PlayerGui") end
for _,par in ipairs({parentGui,LP:WaitForChild("PlayerGui")}) do
    for _,n in ipairs({"luxxs","luxxsKey","luxxsESP","luxxsFPS"}) do local o=par:FindFirstChild(n); if o then o:Destroy() end end
end
local function mkGui(name,order)
    local g=new("ScreenGui",{Name=name,ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=order,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
    local ok=pcall(function() g.Parent=parentGui end)
    if not ok or not g.Parent then g.Parent=LP:WaitForChild("PlayerGui") end
    return g
end
local gui,espGui,fpsGui=mkGui("luxxs",50),mkGui("luxxsESP",8),mkGui("luxxsFPS",100)

local toastHost=new("Frame",{AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-16,1,-16),Size=UDim2.fromOffset(270,320),BackgroundTransparency=1,ZIndex=100,Parent=gui})
new("UIListLayout",{VerticalAlignment=Enum.VerticalAlignment.Bottom,HorizontalAlignment=Enum.HorizontalAlignment.Right,Padding=UDim.new(0,6),Parent=toastHost})
local function notify(text)
    local slot=new("Frame",{Size=UDim2.fromOffset(250,34),BackgroundTransparency=1,Parent=toastHost})
    local f=new("Frame",{Position=UDim2.fromOffset(280,0),Size=UDim2.fromScale(1,1),BackgroundColor3=C.panel,BorderSizePixel=0,Parent=slot}); stroke(f,C.line,1,0)
    local bar=new("Frame",{Size=UDim2.new(0,3,1,0),BorderSizePixel=0,Parent=f}); T(bar,"BackgroundColor3")
    new("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,-20,1,0),Position=UDim2.fromOffset(14,0),Font=F_MONO,TextSize=12,TextColor3=C.text,TextXAlignment=Enum.TextXAlignment.Left,Text=text,Parent=f})
    tween(f,0.4,{Position=UDim2.fromOffset(0,0)})
    task.delay(2.6,function() if not f.Parent then return end tween(f,0.3,{Position=UDim2.fromOffset(280,0)},Enum.EasingStyle.Quint,Enum.EasingDirection.In); task.delay(0.35,function() slot:Destroy() end) end)
end

local function makeDraggable(handle,target,onClick)
    local dragging,startPos,startInput,moved=false,nil,nil,false
    handle.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true; moved=false; startInput=input.Position; startPos=target.Position
            input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then dragging=false; if not moved and onClick then onClick() end end end)
        end
    end)
    track(UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
            local delta=input.Position-startInput
            if delta.Magnitude>5 then moved=true end
            if moved then target.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y) end
        end
    end))
end

-- one shared drag handler for every slider (cheaper than a connection per slider)
local dragFn,dragScroll=nil,nil
track(UIS.InputChanged:Connect(function(i) if dragFn and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then dragFn(i.Position.X) end end))
track(UIS.InputEnded:Connect(function(i) if dragFn and (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) then dragFn=nil; if dragScroll then dragScroll.ScrollingEnabled=true; dragScroll=nil end end end))

-- ===== KEY SCREEN =====
local unlocked,afterKey=false,nil
do
    local sg=mkGui("luxxsKey",999)
    local root=new("CanvasGroup",{Size=UDim2.fromScale(1,1),BackgroundColor3=WHITE,BorderSizePixel=0,Parent=sg})
    gradient(root,90,ColorSequence.new(Color3.fromRGB(20,26,22),Color3.fromRGB(7,9,8)))
    local dots={}
    for i=1,24 do
        local f=new("Frame",{Size=UDim2.fromOffset(math.random(2,4),math.random(2,4)),BackgroundTransparency=0.55+math.random()*0.35,BorderSizePixel=0,Parent=root}); T(f,"BackgroundColor3"); corner(f,2)
        dots[i]={f,math.random(),math.random(),0.01+math.random()*0.03}
    end
    task.spawn(function() while sg.Parent do local t=os.clock(); for _,d in ipairs(dots) do d[1].Position=UDim2.fromScale((d[2]+t*d[4]*0.3)%1,(d[3]-t*d[4])%1) end; task.wait(1/30) end end)
    for _,y in ipairs({0.1,0.9}) do local f=new("Frame",{Position=UDim2.fromScale(0,y),Size=UDim2.new(1,0,0,1),BorderSizePixel=0,BackgroundTransparency=0.85,Parent=root}); T(f,"BackgroundColor3") end
    new("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,18,0.1,8),Size=UDim2.fromOffset(240,16),Font=F_MONO,TextSize=11,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Left,Text="LUXXS // ACCESS",Parent=root})
    new("TextLabel",{BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-18,0.1,8),Size=UDim2.fromOffset(240,16),Font=F_MONO,TextSize=11,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Right,Text="DRHUB",Parent=root})

    local word,LW="LUXXS",62; local total=LW*#word
    local holder=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.36),Size=UDim2.fromOffset(total,84),BackgroundTransparency=1,ClipsDescendants=true,Parent=root})
    local letters={}
    for i=1,#word do letters[i]=new("TextLabel",{BackgroundTransparency=1,Size=UDim2.fromOffset(LW,84),Position=UDim2.fromOffset((i-1)*LW,98),Font=F_HEAD,TextSize=52,Text=word:sub(i,i),TextColor3=C.text,Parent=holder}) end
    local ul=new("Frame",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0.36,52),Size=UDim2.fromOffset(0,2),BorderSizePixel=0,Parent=root}); T(ul,"BackgroundColor3")
    local sub=new("TextLabel",{BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0.36,68),Size=UDim2.fromOffset(300,18),Font=F_MONO,TextSize=12,TextColor3=C.dim,Text="ENTER ACCESS KEY",TextTransparency=1,Parent=root})
    local kp=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.58),Size=UDim2.fromOffset(0,44),BackgroundColor3=C.row,BorderSizePixel=0,Visible=false,ClipsDescendants=true,Parent=root}); local kst=stroke(kp,C.line,1,0)
    local ki=new("TextBox",{BackgroundTransparency=1,Position=UDim2.fromOffset(14,0),Size=UDim2.new(1,-112,1,0),Font=F_MONO,TextSize=14,TextColor3=C.text,PlaceholderText="KEY",PlaceholderColor3=C.dim,Text="",TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,Parent=kp})
    local kb=new("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-6,0.5,0),Size=UDim2.fromOffset(92,32),BorderSizePixel=0,Text="ENTER",Font=F_MONO,TextSize=13,TextColor3=C.bg,AutoButtonColor=false,Parent=kp}); T(kb,"BackgroundColor3")
    local kbar=new("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.fromScale(0,1),Size=UDim2.fromOffset(0,2),BorderSizePixel=0,Parent=kp}); T(kbar,"BackgroundColor3")
    local st=new("TextLabel",{BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0.58,36),Size=UDim2.fromOffset(340,18),Font=F_MONO,TextSize=12,TextColor3=C.dim,Text="",Parent=root})

    task.spawn(function()
        task.wait(0.2)
        for i,l in ipairs(letters) do tween(l,0.7,{Position=UDim2.fromOffset((i-1)*LW,0)}); task.wait(0.09) end
        task.wait(0.3); tween(ul,0.6,{Size=UDim2.fromOffset(total,2)})
        task.wait(0.3); tween(sub,0.4,{TextTransparency=0})
        kp.Visible=true; tween(kp,0.5,{Size=UDim2.fromOffset(340,44)})
        pcall(function() ki:CaptureFocus() end)
    end)
    local function ripple(delay,size)
        task.delay(delay,function()
            local r=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.36),Size=UDim2.fromOffset(40,40),BackgroundTransparency=1,Parent=sg}); corner(r,400)
            local s=stroke(r,ACC,3,0); tween(r,1.1,{Size=UDim2.fromOffset(size,size)}); tween(s,1.1,{Transparency=1,Thickness=1}); task.delay(1.2,function() r:Destroy() end)
        end)
    end
    local function burst()
        for i=1,36 do
            local a=math.rad(i/36*360+math.random(-6,6)); local d=math.random(150,420)
            local f=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.36),BorderSizePixel=0,Size=UDim2.fromOffset(math.random(3,7),math.random(3,7)),BackgroundColor3=ACC,Parent=sg}); corner(f,3)
            tween(f,math.random(70,120)/100,{Position=UDim2.new(0.5,math.cos(a)*d,0.36,math.sin(a)*d),BackgroundTransparency=1,Size=UDim2.fromOffset(1,1)}); task.delay(1.3,function() f:Destroy() end)
        end
    end
    local done=false
    local function tryKey()
        if done then return end
        local txt=string.lower((ki.Text:gsub("^%s+",""):gsub("%s+$","")))
        if VALID_KEYS[txt] then
            done=true; ki.TextEditable=false; st.Text="ACCESS GRANTED"; T(st,"TextColor3")
            tween(kbar,0.7,{Size=UDim2.new(1,0,0,2)},Enum.EasingStyle.Quart)
            task.wait(0.8)
            for i,l in ipairs(letters) do task.delay((i-1)*0.06,function() tween(l,0.3,{TextColor3=ACC}); new("UIStroke",{Color=ACC,Thickness=1.5,Transparency=0.5,Parent=l}) end) end
            ripple(0,1000); ripple(0.2,1500); burst()
            task.wait(1.1)
            for i,l in ipairs(letters) do task.delay((i-1)*0.05,function() tween(l,0.4,{Position=UDim2.fromOffset((i-1)*LW,-110)},Enum.EasingStyle.Quad,Enum.EasingDirection.In) end) end
            tween(ul,0.4,{Size=UDim2.fromOffset(0,2)}); tween(kp,0.4,{Size=UDim2.fromOffset(0,44)}); tween(root,0.7,{GroupTransparency=1})
            task.wait(0.8); sg:Destroy(); unlocked=true
            if afterKey then afterKey() end
        else
            st.Text="INVALID KEY"; st.TextColor3=C.red; tween(kst,0.1,{Color=C.red})
            task.delay(0.6,function() if kp.Parent then tween(kst,0.3,{Color=C.line}); st.Text="" end end)
            local op=kp.Position
            for _,dx in ipairs({-10,10,-6,6,0}) do tween(kp,0.05,{Position=UDim2.new(op.X.Scale,op.X.Offset+dx,op.Y.Scale,op.Y.Offset)},Enum.EasingStyle.Linear); task.wait(0.055) end
        end
    end
    kb.MouseButton1Click:Connect(tryKey)
    ki.FocusLost:Connect(function(enter) if enter then tryKey() end end)
end

-- ===== WINDOW =====
local W,H=930,460
local holder=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(W,H),BackgroundTransparency=1,Visible=false,Parent=gui})
local userScale=new("UIScale",{Parent=holder})
local animF=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Parent=holder})
local animScale=new("UIScale",{Scale=0.9,Parent=animF})
local main=new("CanvasGroup",{Size=UDim2.fromScale(1,1),BackgroundColor3=C.bg,BorderSizePixel=0,GroupTransparency=1,Parent=animF}); BG(main,0)
local mainStroke=stroke(main,ACC,1.4,0.15); T(mainStroke,"Color")
local mainGrad=new("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,WHITE),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(70,70,70)),ColorSequenceKeypoint.new(1,WHITE)}),Parent=mainStroke})
cornerTick(main,0,0,1,1,14,9); cornerTick(main,W,0,-1,1,14,9); cornerTick(main,0,H,1,-1,14,9); cornerTick(main,W,H,-1,-1,14,9)

local function fitScale() local cam=Workspace.CurrentCamera; local vp=cam and cam.ViewportSize or Vector2.new(1280,720); return math.clamp(math.min((vp.X-20)/W,(vp.Y-20)/H),0.3,1.2)*G.size end
local function refit() userScale.Scale=fitScale() end
track(gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(refit))

local top=new("Frame",{Size=UDim2.new(1,0,0,44),BackgroundColor3=C.panel,BorderSizePixel=0,Parent=main}); BG(top,0)
new("Frame",{Position=UDim2.new(0,0,1,-1),Size=UDim2.new(1,0,0,1),BackgroundColor3=C.line,BorderSizePixel=0,Parent=top})
local mark=new("Frame",{Position=UDim2.fromOffset(16,18),Size=UDim2.fromOffset(8,8),Rotation=45,BorderSizePixel=0,Parent=top}); T(mark,"BackgroundColor3")
new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(34,0),Size=UDim2.fromOffset(90,44),Font=F_HEAD,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=C.text,Text="LUXXS",Parent=top})
new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(130,2),Size=UDim2.fromOffset(120,44),Font=F_MONO,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=C.dim,Text="by DrHub",Parent=top})
local crumb=new("TextLabel",{BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-52,0,0),Size=UDim2.fromOffset(260,44),Font=F_MONO,TextSize=11,TextXAlignment=Enum.TextXAlignment.Right,TextColor3=C.dim,Text="v4.2 // MM2",Parent=top})
local closeBtn=new("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-10,0.5,0),Size=UDim2.fromOffset(28,28),BackgroundColor3=C.row,BorderSizePixel=0,Text="X",Font=F_MONO,TextSize=13,TextColor3=C.dim,AutoButtonColor=false,Parent=top})

local side=new("Frame",{Position=UDim2.fromOffset(0,44),Size=UDim2.fromOffset(150,H-44-24),BackgroundColor3=C.panel,BorderSizePixel=0,Parent=main}); BG(side,0)
new("Frame",{Position=UDim2.new(1,-1,0,0),Size=UDim2.new(0,1,1,0),BackgroundColor3=C.line,BorderSizePixel=0,Parent=side})
local sideList=new("Frame",{BackgroundTransparency=1,Position=UDim2.fromOffset(0,10),Size=UDim2.new(1,-1,1,-50),Parent=side})
local indicator=new("Frame",{Size=UDim2.fromOffset(2,22),Position=UDim2.fromOffset(0,16),BorderSizePixel=0,ZIndex=3,Parent=side}); T(indicator,"BackgroundColor3")
local brand=new("TextLabel",{BackgroundTransparency=1,AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,16,1,-10),Size=UDim2.fromOffset(120,22),Font=F_HEAD,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,Text="luxxs",Parent=side}); T(brand,"TextColor3")
local brandS=new("UIStroke",{Thickness=1,Transparency=0.7,Parent=brand}); T(brandS,"Color")

local foot=new("Frame",{Position=UDim2.new(0,0,1,-24),Size=UDim2.new(1,0,0,24),BackgroundColor3=C.panel,BorderSizePixel=0,Parent=main}); BG(foot,0)
new("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=C.line,BorderSizePixel=0,Parent=foot})
new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(166,0),Size=UDim2.new(0.5,0,1,0),Font=F_MONO,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=C.dim,Text="RIGHTSHIFT = TOGGLE   //   DRAG THE TOP BAR OR THE Lx ICON",Parent=foot})
local footR=new("TextLabel",{BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-14,0,0),Size=UDim2.new(0.4,0,1,0),Font=F_MONO,TextSize=10,TextXAlignment=Enum.TextXAlignment.Right,TextColor3=C.dim,Text="ROLE  INNOCENT",Parent=foot})

local pages=new("Frame",{BackgroundTransparency=1,Position=UDim2.fromOffset(162,54),Size=UDim2.fromOffset(494,H-24-54-10),ClipsDescendants=true,Parent=main})
local previewPanel=new("Frame",{Position=UDim2.fromOffset(668,54),Size=UDim2.fromOffset(252,372),BorderSizePixel=0,Parent=main})

-- ===== TABS + CONTROL API (two-column flow, modules with gear, color picker) =====
local tabs,currentTab,switching={},nil,false
local MAXH=335
local function restyleTabs()
    for _,t in ipairs(tabs) do local on=(t==currentTab); t.nm.TextColor3=on and C.text or C.dim; t.num.TextColor3=on and ACC or C.dim; t.button.BackgroundTransparency=on and 0.55 or 1 end
end
local function selectTab(tab)
    if currentTab==tab or switching then return end
    switching=true; local old=currentTab; currentTab=tab
    tween(indicator,0.3,{Position=UDim2.fromOffset(0,16+tab.index*38)}); restyleTabs()
    if old then tween(old.page,0.15,{GroupTransparency=1}); task.delay(0.15,function() old.page.Visible=false end) end
    task.delay(old and 0.12 or 0,function() tab.page.GroupTransparency=1; tab.page.Visible=true; tween(tab.page,0.25,{GroupTransparency=0}); task.delay(0.25,function() switching=false end) end)
end
local function hairline(parent,y) return new("Frame",{Position=UDim2.new(0,0,1,y or -1),Size=UDim2.new(1,0,0,1),BackgroundColor3=C.line,BorderSizePixel=0,Parent=parent}) end
local function rowLabel(r,txt,w) return new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(8,0),Size=UDim2.new(w or 1,w and 0 or -44,0,34),Font=F_BODY,TextSize=15,TextColor3=C.text,TextXAlignment=Enum.TextXAlignment.Left,Text=txt,TextTruncate=Enum.TextTruncate.AtEnd,Parent=r}) end

local function makeApi(place,scroll)
    local api={}
    function api:Label(text)
        local f=new("Frame",{Size=UDim2.new(1,0,0,30),BackgroundTransparency=1,Parent=place(30)})
        new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(0,6),Size=UDim2.new(1,0,0,18),Font=F_SEC,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=C.dim,Text=string.upper(text),Parent=f})
        hairline(f,-3); local ac=new("Frame",{Position=UDim2.new(0,0,1,-3),Size=UDim2.fromOffset(28,1),BorderSizePixel=0,Parent=f}); T(ac,"BackgroundColor3")
    end
    function api:Custom(h) return new("Frame",{Size=UDim2.new(1,0,0,h),BackgroundTransparency=1,Parent=place(h)}) end
    function api:Note(text,h)
        return new("TextLabel",{Size=UDim2.new(1,0,0,h or 18),BackgroundTransparency=1,Font=F_MONO,TextSize=10,TextColor3=C.dim,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,Text=text,Parent=place(h or 18)})
    end
    function api:Toggle(text,key,default,callback)
        local state=default or false
        local row=new("TextButton",{Size=UDim2.new(1,0,0,34),BackgroundColor3=C.row,BackgroundTransparency=1,BorderSizePixel=0,AutoButtonColor=false,Text="",Parent=place(34)}); hairline(row); rowLabel(row,text)
        local box=new("Frame",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-8,0.5,0),Size=UDim2.fromOffset(16,16),BackgroundColor3=C.bg,BorderSizePixel=0,Parent=row})
        local bs=stroke(box,C.off,1,0)
        local inner=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(state and 8 or 0,state and 8 or 0),BorderSizePixel=0,Parent=box}); T(inner,"BackgroundColor3")
        local function paint() bs.Color=state and ACC or C.off; tween(inner,0.15,{Size=UDim2.fromOffset(state and 8 or 0,state and 8 or 0)}) end
        themed[#themed+1]={bs,"Color",function(a) return state and a or C.off end}; bs.Color=state and ACC or C.off
        register(key,state,function(v) state=v and true or false; Flags[key]=state; paint(); if callback then task.spawn(callback,state) end end)
        row.MouseButton1Click:Connect(function() Setters[key](not state); notify(text..(state and "  ON" or "  OFF")) end)
        row.MouseEnter:Connect(function() tween(row,0.12,{BackgroundTransparency=0.5}) end); row.MouseLeave:Connect(function() tween(row,0.12,{BackgroundTransparency=1}) end)
    end
    function api:Button(text,callback)
        local wrap=new("Frame",{Size=UDim2.new(1,0,0,38),BackgroundTransparency=1,Parent=place(38)})
        local b=new("TextButton",{Position=UDim2.fromOffset(6,4),Size=UDim2.new(1,-12,0,30),BackgroundColor3=C.bg,BackgroundTransparency=1,BorderSizePixel=0,AutoButtonColor=false,Font=F_MONO,TextSize=12,Text=string.upper(text),Parent=wrap})
        T(b,"TextColor3"); local bs=stroke(b,ACC,1,0.4); T(bs,"Color")
        b.MouseEnter:Connect(function() b.BackgroundColor3=ACC; tween(b,0.12,{BackgroundTransparency=0}); b.TextColor3=C.bg end)
        b.MouseLeave:Connect(function() tween(b,0.12,{BackgroundTransparency=1}); b.TextColor3=ACC end)
        b.MouseButton1Click:Connect(function() if callback then task.spawn(callback) end end)
        return b
    end
    function api:Input(text,key,default,callback)
        local row=new("Frame",{Size=UDim2.new(1,0,0,38),BackgroundTransparency=1,Parent=place(38)}); hairline(row); rowLabel(row,text,0.4)
        local boxF=new("Frame",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-6,0.5,0),Size=UDim2.new(0.6,-8,0,26),BackgroundColor3=C.bg,BorderSizePixel=0,Parent=row}); local bs=stroke(boxF,ACC,1,0.4); T(bs,"Color")
        local tb=new("TextBox",{BackgroundTransparency=1,Size=UDim2.new(1,-10,1,0),Position=UDim2.fromOffset(5,0),Font=F_MONO,TextSize=12,TextColor3=C.text,PlaceholderColor3=C.dim,PlaceholderText="value",Text=tostring(default or ""),ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Center,Parent=boxF})
        if key then register(key,tostring(default or ""),function(v) Flags[key]=tostring(v); tb.Text=Flags[key]; if callback then task.spawn(callback,Flags[key],tb) end end) end
        tb.FocusLost:Connect(function() if key then Setters[key](tb.Text) elseif callback then task.spawn(callback,tb.Text,tb) end end)
        return tb
    end
    function api:Slider(text,key,min,max,default,callback,fmt,step)
        step=step or 1; local value=default
        local row=new("Frame",{Size=UDim2.new(1,0,0,44),BackgroundTransparency=1,Parent=place(44)}); hairline(row)
        new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(8,3),Size=UDim2.new(0.6,0,0,20),Font=F_BODY,TextSize=15,TextColor3=C.text,TextXAlignment=Enum.TextXAlignment.Left,Text=text,Parent=row})
        local val=new("TextLabel",{BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-8,0,3),Size=UDim2.fromOffset(90,20),Font=F_MONO,TextSize=12,TextXAlignment=Enum.TextXAlignment.Right,Text="",Parent=row}); T(val,"TextColor3")
        local bar=new("Frame",{Position=UDim2.new(0,8,0,32),Size=UDim2.new(1,-16,0,2),BackgroundColor3=C.off,BorderSizePixel=0,Parent=row})
        local fill=new("Frame",{Size=UDim2.fromScale(0,1),BorderSizePixel=0,Parent=bar}); T(fill,"BackgroundColor3")
        local knob=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0,0.5),Size=UDim2.fromOffset(6,14),BackgroundColor3=C.text,BorderSizePixel=0,ZIndex=3,Parent=bar})
        local function apply(v,silent)
            v=math.clamp(math.floor((tonumber(v) or min)/step+0.5)*step,min,max); value=v; Flags[key]=v
            val.Text=fmt and fmt(v) or tostring(v); local r=(v-min)/(max-min)
            if silent then fill.Size=UDim2.fromScale(r,1); knob.Position=UDim2.fromScale(r,0.5)
            else tween(fill,0.08,{Size=UDim2.fromScale(r,1)},Enum.EasingStyle.Linear); tween(knob,0.08,{Position=UDim2.fromScale(r,0.5)},Enum.EasingStyle.Linear) end
            if callback and not silent then task.spawn(callback,v) end
        end
        register(key,default,function(v) apply(v,false) end)
        apply(default,true)
        local hit=new("TextButton",{BackgroundTransparency=1,Text="",Position=UDim2.fromOffset(0,20),Size=UDim2.new(1,0,0,24),Parent=row})
        local function update(x) Setters[key](min+(max-min)*math.clamp((x-bar.AbsolutePosition.X)/math.max(bar.AbsoluteSize.X,1),0,1)) end
        hit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragFn=update; dragScroll=scroll; scroll.ScrollingEnabled=false; update(i.Position.X) end end)
    end
    function api:Choice(text,key,options,default,callback)
        local idx=table.find(options,default) or 1
        local row=new("TextButton",{Size=UDim2.new(1,0,0,34),BackgroundColor3=C.row,BackgroundTransparency=1,BorderSizePixel=0,AutoButtonColor=false,Text="",Parent=place(34)}); hairline(row); rowLabel(row,text,0.45)
        local val=new("TextLabel",{BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-8,0,0),Size=UDim2.new(0.55,-8,1,0),Font=F_MONO,TextSize=11,TextXAlignment=Enum.TextXAlignment.Right,Text="< "..options[idx].." >",Parent=row}); T(val,"TextColor3")
        register(key,options[idx],function(v) local i=table.find(options,v); if not i then return end; idx=i; Flags[key]=options[i]; val.Text="< "..options[i].." >"; if callback then task.spawn(callback,options[i]) end end)
        row.MouseButton1Click:Connect(function() Setters[key](options[idx%#options+1]) end); row.MouseButton2Click:Connect(function() Setters[key](options[(idx-2)%#options+1]) end)
        row.MouseEnter:Connect(function() tween(row,0.12,{BackgroundTransparency=0.5}) end); row.MouseLeave:Connect(function() tween(row,0.12,{BackgroundTransparency=1}) end)
    end
    -- color picker: palette + hue / saturation / brightness ("shade") + rainbow
    function api:Color(text,key,default,callback)
        local def=typeof(default)=="Color3" and hsvOf(default) or copyColor(default)
        local wrap=new("Frame",{Size=UDim2.new(1,0,0,34),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=place(34)})
        new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Parent=wrap})
        local head=new("TextButton",{Size=UDim2.new(1,0,0,34),BackgroundColor3=C.row,BackgroundTransparency=1,BorderSizePixel=0,AutoButtonColor=false,Text="",LayoutOrder=1,Parent=wrap}); hairline(head); rowLabel(head,text,0.55)
        local sw=new("Frame",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-8,0.5,0),Size=UDim2.fromOffset(44,16),BorderSizePixel=0,Parent=head}); corner(sw,3); stroke(sw,C.line,1,0)
        local panel=new("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Visible=false,LayoutOrder=2,Parent=wrap})
        new("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder,Parent=panel}); new("UIPadding",{PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6),PaddingTop=UDim.new(0,6),PaddingBottom=UDim.new(0,6),Parent=panel})
        local grid=new("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,LayoutOrder=1,Parent=panel})
        new("UIGridLayout",{CellSize=UDim2.fromOffset(22,22),CellPadding=UDim2.fromOffset(5,5),Parent=grid})
        local cur
        local sliders={}
        local function refreshAll() sw.BackgroundColor3=colorOf(cur,os.clock()); for _,f in ipairs(sliders) do f() end end
        local function mini(label,get,set,order)
            local r=new("Frame",{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,LayoutOrder=order,Parent=panel})
            new("TextLabel",{BackgroundTransparency=1,Size=UDim2.fromOffset(44,22),Font=F_MONO,TextSize=10,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Left,Text=label,Parent=r})
            local bar=new("Frame",{Position=UDim2.new(0,48,0.5,-1),Size=UDim2.new(1,-52,0,3),BackgroundColor3=C.off,BorderSizePixel=0,Parent=r})
            local fill=new("Frame",{Size=UDim2.fromScale(get(),1),BorderSizePixel=0,Parent=bar}); T(fill,"BackgroundColor3")
            local knob=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(get(),0.5),Size=UDim2.fromOffset(6,12),BackgroundColor3=C.text,BorderSizePixel=0,ZIndex=3,Parent=bar})
            local hit=new("TextButton",{BackgroundTransparency=1,Text="",Size=UDim2.fromScale(1,1),Parent=r})
            local function upd(x) set(math.clamp((x-bar.AbsolutePosition.X)/math.max(bar.AbsoluteSize.X,1),0,1)) end
            hit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragFn=upd; dragScroll=scroll; scroll.ScrollingEnabled=false; upd(i.Position.X) end end)
            sliders[#sliders+1]=function() local v=get(); fill.Size=UDim2.fromScale(v,1); knob.Position=UDim2.fromScale(v,0.5) end
        end
        local function commit() Flags[key]=copyColor(cur); refreshAll(); if callback then task.spawn(callback,Flags[key]) end end
        register(key,def,function(v) if type(v)=="table" and v.h then cur=copyColor(v); commit() end end)
        cur=copyColor(def)
        local presets={Color3.fromRGB(86,255,126),Color3.fromRGB(196,255,61),Color3.fromRGB(0,220,255),Color3.fromRGB(110,214,255),Color3.fromRGB(70,110,255),Color3.fromRGB(158,110,255),Color3.fromRGB(255,110,200),Color3.fromRGB(255,60,60),Color3.fromRGB(255,150,40),Color3.fromRGB(255,214,10),Color3.fromRGB(255,255,255),Color3.fromRGB(150,150,160)}
        for _,pc in ipairs(presets) do
            local b=new("TextButton",{BackgroundColor3=pc,BorderSizePixel=0,Text="",AutoButtonColor=false,Parent=grid}); corner(b,4)
            b.MouseButton1Click:Connect(function() cur=hsvOf(pc); commit() end)
        end
        mini("HUE",function() return cur.h end,function(v) cur.h=v; cur.rb=false; commit() end,2)
        mini("SAT",function() return cur.s end,function(v) cur.s=v; cur.rb=false; commit() end,3)
        mini("SHADE",function() return cur.v end,function(v) cur.v=v; commit() end,4)
        local rb=new("TextButton",{Size=UDim2.new(1,0,0,24),BackgroundTransparency=1,Text="",LayoutOrder=5,Parent=panel})
        local rbL=new("TextLabel",{BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Font=F_MONO,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Text="",Parent=rb})
        sliders[#sliders+1]=function() rbL.Text=(cur.rb and "[x] " or "[ ] ").."RAINBOW"; rbL.TextColor3=cur.rb and ACC or C.dim end
        rb.MouseButton1Click:Connect(function() cur.rb=not cur.rb; commit() end)
        head.MouseButton1Click:Connect(function() panel.Visible=not panel.Visible end)
        head.MouseEnter:Connect(function() tween(head,0.12,{BackgroundTransparency=0.5}) end); head.MouseLeave:Connect(function() tween(head,0.12,{BackgroundTransparency=1}) end)
        refreshAll()
        task.spawn(function() while wrap.Parent do if cur.rb then sw.BackgroundColor3=colorOf(cur,os.clock()) end; task.wait(0.1) end end)
    end
    -- module row: checkbox + gear; the gear opens that module's settings
    function api:Module(text,key,default,callback,build)
        local state=default or false
        local wrap=new("Frame",{Size=UDim2.new(1,0,0,34),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=place(34)})
        new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Parent=wrap})
        local head=new("TextButton",{Size=UDim2.new(1,0,0,34),BackgroundColor3=C.row,BackgroundTransparency=1,BorderSizePixel=0,AutoButtonColor=false,Text="",LayoutOrder=1,Parent=wrap}); hairline(head)
        rowLabel(head,text,1).Size=UDim2.new(1,-76,0,34)
        local box=new("Frame",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-8,0.5,0),Size=UDim2.fromOffset(16,16),BackgroundColor3=C.bg,BorderSizePixel=0,Parent=head}); local bs=stroke(box,C.off,1,0)
        local inner=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(state and 8 or 0,state and 8 or 0),BorderSizePixel=0,Parent=box}); T(inner,"BackgroundColor3")
        local function paint() bs.Color=state and ACC or C.off; tween(inner,0.15,{Size=UDim2.fromOffset(state and 8 or 0,state and 8 or 0)}) end
        themed[#themed+1]={bs,"Color",function(a) return state and a or C.off end}; bs.Color=state and ACC or C.off
        register(key,state,function(v) state=v and true or false; Flags[key]=state; paint(); if callback then task.spawn(callback,state) end end)
        local gear=new("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-32,0.5,0),Size=UDim2.fromOffset(22,22),BackgroundTransparency=1,Text="",ZIndex=3,Parent=head})
        local gi=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(18,18),BackgroundTransparency=1,Parent=gear})
        local ring=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(10,10),BackgroundTransparency=1,Parent=gi}); corner(ring,5); local rs=stroke(ring,C.dim,2,0)
        local teeth={}
        for a=0,3 do local tt=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(3,18),BackgroundColor3=C.dim,BorderSizePixel=0,Rotation=a*45,Parent=gi}); teeth[#teeth+1]=tt end
        local settings=new("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=C.panel,BackgroundTransparency=0.3,BorderSizePixel=0,Visible=false,LayoutOrder=2,Parent=wrap})
        new("UIListLayout",{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder,Parent=settings}); new("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingBottom=UDim.new(0,6),PaddingTop=UDim.new(0,4),Parent=settings})
        local open=false
        gear.MouseButton1Click:Connect(function() open=not open; settings.Visible=open; tween(gi,0.3,{Rotation=open and 90 or 0}); for _,tt in ipairs(teeth) do tt.BackgroundColor3=open and ACC or C.dim end; rs.Color=open and ACC or C.dim end)
        head.MouseButton1Click:Connect(function() Setters[key](not state); notify(text..(state and "  ON" or "  OFF")) end)
        head.MouseEnter:Connect(function() tween(head,0.12,{BackgroundTransparency=0.5}) end); head.MouseLeave:Connect(function() tween(head,0.12,{BackgroundTransparency=1}) end)
        if build then build(makeApi(function() return settings end,scroll)) end
    end
    return api
end

local function createTab(name)
    local index=#tabs
    local button=new("TextButton",{Size=UDim2.new(1,0,0,34),Position=UDim2.fromOffset(0,index*38+6),BackgroundColor3=C.row,BackgroundTransparency=1,BorderSizePixel=0,Text="",AutoButtonColor=false,Parent=sideList})
    local num=new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(16,0),Size=UDim2.fromOffset(24,34),Font=F_MONO,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=C.dim,Text=string.format("%02d",index+1),Parent=button})
    local nm=new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(46,0),Size=UDim2.new(1,-50,1,0),Font=F_SEC,TextSize=16,TextXAlignment=Enum.TextXAlignment.Left,TextColor3=C.dim,Text=string.upper(name),Parent=button})
    local page=new("CanvasGroup",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false,GroupTransparency=1,Parent=pages})
    local scroll=new("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,Parent=page}); T(scroll,"ScrollBarImageColor3")
    new("UIPadding",{PaddingRight=UDim.new(0,8),PaddingTop=UDim.new(0,2),PaddingBottom=UDim.new(0,10),Parent=scroll})
    local cols=new("Frame",{Size=UDim2.fromScale(1,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=scroll})
    new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,10),Parent=cols})
    local function col() local f=new("Frame",{Size=UDim2.new(0.5,-5,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Parent=cols}); new("UIListLayout",{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder,Parent=f}); return f end
    local cl,cr=col(),col(); local used,cur=0,1
    local function place(h) if cur==1 and used+h>MAXH then cur=2; used=0 end; used+=h; return cur==1 and cl or cr end
    local tab=makeApi(place,scroll)
    tab.button,tab.page,tab.index,tab.name,tab.num,tab.nm=button,page,index,name,num,nm; tabs[#tabs+1]=tab
    button.MouseButton1Click:Connect(function() selectTab(tab) end)
    button.MouseEnter:Connect(function() if currentTab~=tab then tween(nm,0.15,{TextColor3=C.text}) end end)
    button.MouseLeave:Connect(function() if currentTab~=tab then tween(nm,0.15,{TextColor3=C.dim}) end end)
    return tab
end

-- ===== OPEN / CLOSE / ICON =====
local isOpen,busy=false,false
local function openMenu()
    if busy or isOpen then return end
    busy=true; isOpen=true; holder.Visible=true; refit(); animScale.Scale=0.9; main.GroupTransparency=1
    tween(animScale,0.4,{Scale=1},Enum.EasingStyle.Back); tween(main,0.3,{GroupTransparency=0}); task.delay(0.4,function() busy=false end)
end
local function closeMenu()
    if busy or not isOpen then return end
    busy=true; isOpen=false
    tween(animScale,0.25,{Scale=0.92},Enum.EasingStyle.Quint,Enum.EasingDirection.In); tween(main,0.25,{GroupTransparency=1},Enum.EasingStyle.Quint,Enum.EasingDirection.In)
    task.delay(0.27,function() holder.Visible=false; busy=false end)
end
local function toggleMenu() if isOpen then closeMenu() else openMenu() end end
closeBtn.MouseButton1Click:Connect(closeMenu)
closeBtn.MouseEnter:Connect(function() tween(closeBtn,0.12,{BackgroundColor3=Color3.fromRGB(190,56,56)}); closeBtn.TextColor3=WHITE end)
closeBtn.MouseLeave:Connect(function() tween(closeBtn,0.12,{BackgroundColor3=C.row}); closeBtn.TextColor3=C.dim end)

local icon=new("TextButton",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromOffset(52,200),Size=UDim2.fromOffset(0,0),BackgroundColor3=C.bg,BorderSizePixel=0,AutoButtonColor=false,Text="",Visible=false,ZIndex=5,Parent=gui}); corner(icon,40)
local iconStroke=stroke(icon,ACC,2.5,0); T(iconStroke,"Color")
local iconGrad=new("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,WHITE),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(40,40,40)),ColorSequenceKeypoint.new(1,WHITE)}),Parent=iconStroke})
local iconGlow=new("UIStroke",{Thickness=7,Transparency=0.82,Parent=icon}); T(iconGlow,"Color")
local iconL=new("TextLabel",{BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,-7,0.5,0),Size=UDim2.fromOffset(16,20),Font=F_HEAD,TextSize=16,TextColor3=C.text,Text="L",ZIndex=6,Parent=icon})
local iconX=new("TextLabel",{BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,8,0.5,0),Size=UDim2.fromOffset(16,20),Font=F_HEAD,TextSize=16,Text="x",ZIndex=6,Parent=icon}); T(iconX,"TextColor3")
icon.MouseEnter:Connect(function() tween(icon,0.2,{Size=UDim2.fromOffset(62,62)},Enum.EasingStyle.Back) end)
icon.MouseLeave:Connect(function() tween(icon,0.2,{Size=UDim2.fromOffset(54,54)}) end)
makeDraggable(icon,icon,toggleMenu); makeDraggable(top,holder)
track(UIS.InputBegan:Connect(function(input,processed) if not processed and unlocked and input.KeyCode==Enum.KeyCode.RightShift then toggleMenu() end end))
afterKey=function()
    local home=icon.Position; icon.Position=UDim2.fromScale(0.5,0.5); icon.Visible=true
    tween(icon,0.5,{Size=UDim2.fromOffset(72,72)},Enum.EasingStyle.Back); task.wait(0.5)
    tween(icon,0.85,{Position=home,Size=UDim2.fromOffset(54,54)}); task.wait(0.4); openMenu()
    notify("Key accepted // RightShift or Lx icon")
end

-- =====================================================================
-- FEATURES (each block is scoped so the main chunk stays under the local limit)
-- =====================================================================
local X={}
local plist=Players:GetPlayers()
track(Players.PlayerAdded:Connect(function() plist=Players:GetPlayers() end))
track(Players.PlayerRemoving:Connect(function() task.defer(function() plist=Players:GetPlayers() end) end))

local function scanName(name)
    local n=string.lower(name)
    if n:find("knife") then return "Murderer" end
    if n:find("revolver") or (n:find("gun") and not n:find("shotgun") and not n:find("stun")) then return "Sheriff" end
    return nil
end
local function toolRole(c) if not c then return nil end for _,o in ipairs(c:GetChildren()) do if o:IsA("Tool") then local r=scanName(o.Name); if r then return r end end end return nil end
local function getRole(plr)
    if plr.Team then local tl=string.lower(plr.Team.Name); if tl=="murderer" then return "Murderer" elseif tl=="sheriff" then return "Sheriff" elseif tl=="innocent" then return "Innocent" end end
    for _,src in ipairs({plr,plr.Character}) do
        for _,attr in ipairs({"Role","MM2Role","role"}) do
            local v=src:GetAttribute(attr)
            if v~=nil then local rl=string.lower(tostring(v)); if rl=="murderer" or rl=="murder" then return "Murderer" elseif rl=="sheriff" then return "Sheriff" elseif rl=="innocent" then return "Innocent" end end
        end
    end
    return toolRole(plr.Character) or toolRole(plr:FindFirstChildOfClass("Backpack")) or "Innocent"
end
local roleCache={}
local function getRoleCached(plr)
    local c=roleCache[plr]; local now=os.clock()
    if c and now-c.t<0.25 then return c.r end
    local r=getRole(plr); roleCache[plr]={r=r,t=now}; return r
end
track(Players.PlayerRemoving:Connect(function(p) roleCache[p]=nil end))
local function isAlive(plr)
    local c=plr.Character; local h=c and c:FindFirstChildOfClass("Humanoid"); local r=c and c:FindFirstChild("HumanoidRootPart")
    return (h and r and h.Health>0) and true or false,c,h,r
end

-- ===== ESP + CHAMS (chams run on their own path so they never depend on on-screen checks) =====
do
    local esp={}
    local R15={{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}}
    local R6={{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}
    local UP_T,UP_B=Vector3.new(0,2.7,0),Vector3.new(0,-3.1,0)
    local CORN={}
    for xi,x in ipairs({-1.9,1.9}) do for yi,y in ipairs({-3.1,2.7}) do for zi,z in ipairs({-1.1,1.1}) do CORN[(xi-1)*4+(yi-1)*2+zi]=Vector3.new(x,y,z) end end end
    local EDGES={{1,2},{3,4},{5,6},{7,8},{1,3},{2,4},{5,7},{6,8},{1,5},{2,6},{3,7},{4,8}}
    local function eLine() return new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),BorderSizePixel=0,Visible=false,Parent=espGui}) end
    local function eText(sz,ay) return new("TextLabel",{AnchorPoint=Vector2.new(0.5,ay),Size=UDim2.fromOffset(200,sz+2),BackgroundTransparency=1,Font=F_MONO,TextSize=sz,TextColor3=WHITE,TextStrokeTransparency=0.4,Visible=false,Parent=espGui}) end
    local function mkEsp()
        local d={shown=false,e3={},sk={}}
        d.box=new("Frame",{BackgroundTransparency=1,BorderSizePixel=0,Visible=false,Parent=espGui}); d.bs=stroke(d.box,WHITE,1.5,0)
        for i=1,12 do d.e3[i]=eLine() end
        for i=1,14 do d.sk[i]=eLine() end
        d.role,d.name,d.dist=eText(13,1),eText(12,1),eText(11,0)
        d.hpBg=new("Frame",{BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.4,BorderSizePixel=0,Visible=false,Parent=espGui})
        d.hp=new("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.fromScale(0,1),BorderSizePixel=0,Parent=d.hpBg})
        d.tr=eLine()
        return d
    end
    local function hideEsp(d)
        if not d.shown then return end
        d.shown=false; d.box.Visible,d.role.Visible,d.name.Visible,d.dist.Visible,d.hpBg.Visible,d.tr.Visible=false,false,false,false,false,false
        for _,l in ipairs(d.e3) do l.Visible=false end for _,l in ipairs(d.sk) do l.Visible=false end
    end
    function X.killEsp(p)
        local d=esp[p]; if not d then return end
        for _,v in pairs(d) do if typeof(v)=="Instance" then pcall(function() v:Destroy() end) end end
        for _,l in ipairs(d.e3) do l:Destroy() end for _,l in ipairs(d.sk) do l:Destroy() end
        esp[p]=nil
    end
    track(Players.PlayerRemoving:Connect(X.killEsp))
    function X.killAllEsp() for p in pairs(esp) do X.killEsp(p) end end
    local function bindChar(d,ch)
        if d.char==ch then if ch and (not d.hrp or not d.hum) then d.hrp,d.hum=ch:FindFirstChild("HumanoidRootPart"),ch:FindFirstChildOfClass("Humanoid") end return end
        d.char,d.hrp,d.hum,d.pairs=ch,nil,nil,nil
        if ch then
            d.hrp,d.hum=ch:FindFirstChild("HumanoidRootPart"),ch:FindFirstChildOfClass("Humanoid")
            local prs={}
            for _,pr in ipairs(ch:FindFirstChild("UpperTorso") and R15 or R6) do local a,b=ch:FindFirstChild(pr[1]),ch:FindFirstChild(pr[2]); if a and b then prs[#prs+1]={a,b} end end
            d.pairs=prs
        end
    end
    local wasOn=false
    function X.espStep(cam,t)
        local any=Flags.box or Flags.name or Flags.dist or Flags.hp or Flags.skel or Flags.tracer or Flags.role
        local chOn=Flags.chams or Flags.glow
        if not any and not chOn and not wasOn then return end
        wasOn=any or chOn
        local vp,camPos=cam.ViewportSize,cam.CFrame.Position
        local ecolBase,chamC,glowC=colorOf(Flags.espCol,t),colorOf(Flags.chamCol,t),colorOf(Flags.glowCol,t)
        local pulse=Flags.chamPulse and (0.5+0.5*math.sin(t*3)) or 0
        for _,p in ipairs(plist) do if p~=LP then
            local ch=p.Character; local d=esp[p]; local alive=false
            if ch and (any or chOn) then
                if not d then d=mkEsp(); esp[p]=d end
                bindChar(d,ch)
                alive=(d.hrp and d.hum and d.hum.Health>0 and (d.hrp.Position-camPos).Magnitude<=Flags.espDist) and true or false
            elseif d then bindChar(d,nil) end
            local role=(alive and (Flags.colorByRole or Flags.role)) and getRoleCached(p) or "Innocent"
            local rcol=ROLE_COLORS[role] or WHITE
            local ecol=Flags.colorByRole and rcol or ecolBase
            -- chams / glow: one Highlight parented to the character (stays alive through respawns, never tied to screen visibility)
            if d then
                local hl=d.hl
                if alive and chOn then
                    if not hl or hl.Parent~=ch then if hl then hl:Destroy() end hl=new("Highlight",{Name="luxxsHL",Parent=ch}); d.hl=hl end
                    hl.Adornee=ch; hl.Enabled=true
                    hl.DepthMode=Flags.chamWalls and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
                    hl.FillColor=Flags.colorByRole and rcol or chamC; hl.OutlineColor=Flags.colorByRole and rcol or glowC
                    hl.FillTransparency=Flags.chams and math.clamp(Flags.chamTrans/100+pulse*0.25,0,1) or 1
                    hl.OutlineTransparency=Flags.glow and (0.1+pulse*0.3) or (Flags.chams and 0.6 or 1)
                elseif hl then hl.Enabled=false end
            end
            if d then
                if alive and any then
                    local hrp,hum,pos=d.hrp,d.hum,d.hrp.Position
                    local top,bot=cam:WorldToViewportPoint(pos+UP_T),cam:WorldToViewportPoint(pos+UP_B)
                    if top.Z>0 and bot.Z>0 then
                        d.shown=true
                        local h=bot.Y-top.Y; local w=h*0.55; local mx=(top.X+bot.X)/2
                        if Flags.box and Flags.boxStyle=="2D" then d.box.Visible=true; d.box.Position=UDim2.fromOffset(mx-w/2,top.Y); d.box.Size=UDim2.fromOffset(w,h); d.bs.Color=ecol else d.box.Visible=false end
                        local ok3=false
                        if Flags.box and Flags.boxStyle=="3D" then
                            local _,yaw=hrp.CFrame:ToOrientation(); local base=CFrame.new(pos)*CFrame.Angles(0,yaw,0); local pts,okp={},true
                            for i=1,8 do local v=cam:WorldToViewportPoint(base*CORN[i]); if v.Z<=0 then okp=false break end pts[i]=v end
                            if okp then ok3=true; for i,e in ipairs(EDGES) do local a,b=pts[e[1]],pts[e[2]]; setLine(d.e3[i],a.X,a.Y,b.X,b.Y,1.5,ecol) end end
                        end
                        if not ok3 then for _,l in ipairs(d.e3) do l.Visible=false end end
                        if Flags.name then d.name.Visible=true; d.name.Text=p.DisplayName~=p.Name and (p.DisplayName.." (@"..p.Name..")") or p.Name; d.name.TextColor3=ecol; d.name.Position=UDim2.fromOffset(mx,top.Y-(Flags.role and 18 or 3)) else d.name.Visible=false end
                        if Flags.role then d.role.Visible=true; d.role.Text=string.upper(role); d.role.TextColor3=rcol; d.role.Position=UDim2.fromOffset(mx,top.Y-3) else d.role.Visible=false end
                        if Flags.dist then d.dist.Visible=true; d.dist.Text="["..math.floor((camPos-pos).Magnitude).."m]"; d.dist.Position=UDim2.fromOffset(mx,bot.Y+2) else d.dist.Visible=false end
                        if Flags.hp then local fr=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1); d.hpBg.Visible=true; d.hpBg.Position=UDim2.fromOffset(mx-w/2-7,top.Y); d.hpBg.Size=UDim2.fromOffset(3,h); d.hp.Size=UDim2.fromScale(1,fr); d.hp.BackgroundColor3=Color3.fromHSV(0.33*fr,0.9,1) else d.hpBg.Visible=false end
                        if Flags.tracer then setLine(d.tr,vp.X/2,vp.Y,mx,bot.Y,1.2,ecol) else d.tr.Visible=false end
                        if Flags.skel and d.pairs then
                            for i=1,14 do
                                local pr,l=d.pairs[i],d.sk[i]
                                if pr then local s1,s2=cam:WorldToViewportPoint(pr[1].Position),cam:WorldToViewportPoint(pr[2].Position); if s1.Z>0 and s2.Z>0 then setLine(l,s1.X,s1.Y,s2.X,s2.Y,1.5,ecol) else l.Visible=false end else l.Visible=false end
                            end
                        else for _,l in ipairs(d.sk) do l.Visible=false end end
                    else hideEsp(d) end
                else hideEsp(d) end
            end
        end end
    end
end

-- ===== GUN ESP (dropped sheriff gun through walls) + teleport =====
do
    local set,vis={}, {}
    local folder=new("Folder",{Name="luxxsGun",Parent=gui})
    local NAMES={GunDrop=true,["Gun Drop"]=true,DroppedGun=true,SheriffGun=true}
    local function partOf(o)
        if o:IsA("BasePart") and NAMES[o.Name] then return o end
        if o:IsA("Tool") and o.Parent==Workspace and scanName(o.Name)=="Sheriff" then return o:FindFirstChild("Handle") or o:FindFirstChildWhichIsA("BasePart") end
        return nil
    end
    local function valid(p) if not p or not p.Parent then return false end if NAMES[p.Name] then return p:IsDescendantOf(Workspace) end local tl=p.Parent; return tl:IsA("Tool") and tl.Parent==Workspace end
    local function add(o) local p=partOf(o); if p then set[p]=true end end
    local function drop(p) local v=vis[p]; if not v then return end pcall(function() v.hl:Destroy() end); pcall(function() v.bb:Destroy() end); vis[p]=nil end
    for _,o in ipairs(Workspace:GetDescendants()) do add(o) end
    track(Workspace.DescendantAdded:Connect(add))
    track(Workspace.DescendantRemoving:Connect(function(o) if set[o] then set[o]=nil; drop(o) end end))
    function X.teleportToGun()
        local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local best,bd
        for p in pairs(set) do if valid(p) then local dd=(p.Position-hrp.Position).Magnitude; if not bd or dd<bd then best,bd=p,dd end end end
        if not best then notify("Gun not found") return end
        hrp.CFrame=CFrame.new(best.Position+Vector3.new(0,3,0)); hrp.AssemblyLinearVelocity=Vector3.zero; notify("Teleported to gun")
    end
    function X.gunStep(cam,t)
        local on=Flags.gunEsp
        for p in pairs(set) do
            if not valid(p) then set[p]=nil; drop(p)
            elseif on then
                local v=vis[p]
                if not v then
                    local hl=new("Highlight",{DepthMode=Enum.HighlightDepthMode.AlwaysOnTop,FillTransparency=0.35,OutlineTransparency=0,Adornee=p,Parent=folder})
                    local bb=new("BillboardGui",{AlwaysOnTop=true,Size=UDim2.fromOffset(120,34),StudsOffset=Vector3.new(0,2.5,0),Adornee=p,Parent=folder})
                    local l=new("TextLabel",{BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Font=F_MONO,TextSize=13,TextStrokeTransparency=0.3,Text="GUN",Parent=bb})
                    v={hl=hl,bb=bb,lbl=l}; vis[p]=v
                end
                local col=colorOf(Flags.gunCol,t); v.hl.FillColor=col; v.hl.OutlineColor=col; v.lbl.TextColor3=col
                v.lbl.Text="GUN ["..(cam and math.floor((p.Position-cam.CFrame.Position).Magnitude) or 0).."m]"
            else drop(p) end
        end
    end
    function X.killGun() for p in pairs(vis) do drop(p) end pcall(function() folder:Destroy() end) end
end

-- ===== TARGETING / AIMBOT / SILENT AIM =====
do
    local CLOSEST={"Head","Chest","Stomach"}
    local function resolvePart(ch,n)
        if n=="Head" then return ch:FindFirstChild("Head")
        elseif n=="Chest" then return ch:FindFirstChild("UpperTorso") or ch:FindFirstChild("Torso")
        elseif n=="Stomach" then return ch:FindFirstChild("LowerTorso") or ch:FindFirstChild("Torso")
        elseif n=="Left Arm" then return ch:FindFirstChild("LeftUpperArm") or ch:FindFirstChild("Left Arm")
        elseif n=="Right Arm" then return ch:FindFirstChild("RightUpperArm") or ch:FindFirstChild("Right Arm")
        elseif n=="Left Leg" then return ch:FindFirstChild("LeftUpperLeg") or ch:FindFirstChild("Left Leg")
        elseif n=="Right Leg" then return ch:FindFirstChild("RightUpperLeg") or ch:FindFirstChild("Right Leg") end
        return ch:FindFirstChild("HumanoidRootPart")
    end
    local rayP=RaycastParams.new(); rayP.FilterType=Enum.RaycastFilterType.Exclude; rayP.IgnoreWater=true
    pcall(function() rayP.RespectCanCollide=true end)
    local function visible(origin,ch,pos)
        rayP.FilterDescendantsInstances={LP.Character}
        local r=Workspace:Raycast(origin,pos-origin,rayP)
        return r==nil or r.Instance:IsDescendantOf(ch)
    end
    -- returns player, part, aim position (with optional prediction); never targets through walls when wall=true
    local function pickTarget(cfg)
        local cam=Workspace.CurrentCamera; if not cam then return nil end
        local vp=cam.ViewportSize; local ctr=Vector2.new(vp.X/2,vp.Y/2); local origin=cam.CFrame.Position
        local myRole=cfg.smart and getRoleCached(LP) or nil
        local bp,bpart,bd=nil,nil,cfg.fov
        for _,plr in ipairs(plist) do
            if plr~=LP then
                local ok,ch,hum=isAlive(plr)
                if ok and (not cfg.smart or myRole=="Murderer" or getRoleCached(plr)=="Murderer") then
                    for _,n in ipairs(cfg.part=="Closest" and CLOSEST or {cfg.part}) do
                        local part=resolvePart(ch,n)
                        if part then
                            local sp=cam:WorldToViewportPoint(part.Position)
                            if sp.Z>0 then
                                local dd=(Vector2.new(sp.X,sp.Y)-ctr).Magnitude
                                if dd<bd and (not cfg.wall or visible(origin,ch,part.Position)) then bp,bpart,bd=plr,part,dd end
                            end
                        end
                    end
                end
            end
        end
        if not bp then return nil end
        local pos=bpart.Position
        if cfg.predict and cfg.predict>0 then pos=pos+bpart.AssemblyLinearVelocity*(cfg.predict/100) end
        return bp,bpart,pos
    end
    X.pickTarget=pickTarget

    pcall(function() RunService:UnbindFromRenderStep("luxxsAim") end)
    RunService:BindToRenderStep("luxxsAim",Enum.RenderPriority.Camera.Value+1,function(dt)
        if not Flags.aim then return end
        local cam=Workspace.CurrentCamera; if not cam then return end
        if Flags.aimAct=="Hold RMB" and not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
        local plr,part,pos=pickTarget({fov=Flags.aimFov,part=Flags.aimPart,wall=Flags.aimWall,smart=Flags.aimSmart,predict=Flags.aimPredict})
        if pos then
            local a=1
            if Flags.aimMode=="Smooth" then a=1-math.exp(-(1.5+26*(1-Flags.aimSmooth/100))*dt) end
            cam.CFrame=cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position,pos),a)
        end
    end)

    -- silent aim: redirects the shot (Mouse.Hit / Mouse.Target / Raycast) without moving the camera.
    -- Needs an executor with hookmetamethod; otherwise "Flick" mode is used (camera snaps for 2 frames on click).
    local Silent={pos=nil,part=nil,allow=true,hooked=false}
    local function installHooks()
        if Silent.hooked then return true end
        if not (hookmetamethod and newcclosure and getnamecallmethod) then return false end
        local chk=checkcaller or function() return false end
        local ok=pcall(function()
            local oldIndex; oldIndex=hookmetamethod(game,"__index",newcclosure(function(self,key)
                if Silent.pos and self==mouse and not chk() then
                    if key=="Hit" then return CFrame.new(Silent.pos) elseif key=="Target" then return Silent.part end
                end
                return oldIndex(self,key)
            end))
            local oldNC; oldNC=hookmetamethod(game,"__namecall",newcclosure(function(self,...)
                if Silent.pos and self==Workspace and not chk() and getnamecallmethod()=="Raycast" then
                    local origin,dir,params=...
                    if typeof(origin)=="Vector3" and typeof(dir)=="Vector3" then
                        local d=Silent.pos-origin
                        return oldNC(self,origin,d.Unit*math.max(dir.Magnitude,d.Magnitude),params)
                    end
                end
                return oldNC(self,...)
            end))
        end)
        Silent.hooked=ok
        return ok
    end
    X.installSilent=function() if not installHooks() then notify("hookmetamethod missing: using Flick mode") end end

    local mark=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.fromOffset(18,18),BackgroundTransparency=1,Visible=false,ZIndex=3,Parent=espGui}); corner(mark,9)
    local markS=stroke(mark,ACC,1.5,0); T(markS,"Color")
    local sfov=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),BackgroundTransparency=1,Visible=false,Parent=espGui}); corner(sfov,500)
    local sfovS=stroke(sfov,Color3.fromRGB(255,214,10),1.2,0.4)
    function X.silentStep(cam,t)
        local on=Flags.silent
        sfov.Visible=(on and Flags.silentFov)==true
        if sfov.Visible then local r=Flags.silentRadius*2; sfov.Size=UDim2.fromOffset(r,r); sfovS.Color=colorOf(Flags.silentCol,t) end
        if not on then Silent.pos=nil; Silent.part=nil; mark.Visible=false; return end
        local plr,part,pos=pickTarget({fov=Flags.silentRadius,part=Flags.silentPart,wall=Flags.silentWall,smart=Flags.silentSmart,predict=Flags.silentPredict})
        if pos and Silent.allow then
            Silent.pos,Silent.part=pos,part
            if Flags.silentMark then local sp=cam:WorldToViewportPoint(pos); mark.Visible=sp.Z>0; mark.Position=UDim2.fromOffset(sp.X,sp.Y) else mark.Visible=false end
        else Silent.pos,Silent.part=nil,nil; mark.Visible=false end
    end
    track(UIS.InputBegan:Connect(function(i,gp)
        if gp then return end
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            Silent.allow=math.random(1,100)<=Flags.silentChance
            if Flags.silent and Silent.pos and (Flags.silentMethod=="Flick" or not Silent.hooked) then
                local cam=Workspace.CurrentCamera; local old=cam.CFrame
                cam.CFrame=CFrame.lookAt(old.Position,Silent.pos)
                task.spawn(function() RunService.RenderStepped:Wait(); RunService.RenderStepped:Wait(); if cam.Parent then cam.CFrame=old end end)
            end
        end
    end))
end

-- ===== CHARACTER: fly / noclip / spin / speed / jump =====
do
    local fly={on=false,vel=Vector3.zero,up=false,dn=false}
    local function flyStop(hum)
        for _,k in ipairs({"lv","ao","att"}) do if fly[k] then pcall(function() fly[k]:Destroy() end); fly[k]=nil end end
        fly.vel=Vector3.zero
        if fly.on and hum and hum.Parent then hum.PlatformStand=false; pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end) end
        fly.on=false
    end
    local function flyStart(hrp,hum)
        flyStop(nil)
        fly.att=new("Attachment",{Name="LxFlyA",Parent=hrp})
        fly.lv=new("LinearVelocity",{Attachment0=fly.att,MaxForce=math.huge,VelocityConstraintMode=Enum.VelocityConstraintMode.Vector,VectorVelocity=Vector3.zero,RelativeTo=Enum.ActuatorRelativeTo.World,Parent=hrp})
        fly.ao=new("AlignOrientation",{Mode=Enum.OrientationAlignmentMode.OneAttachment,Attachment0=fly.att,MaxTorque=math.huge,Responsiveness=60,RigidityEnabled=false,CFrame=hrp.CFrame-hrp.CFrame.Position,Parent=hrp})
        hum.PlatformStand=true; fly.on=true
    end
    local function mkBtn(txt,y)
        local b=new("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-24,0.5,y),Size=UDim2.fromOffset(56,46),BackgroundColor3=C.bg,BackgroundTransparency=0.1,BorderSizePixel=0,Text=txt,Font=F_MONO,TextSize=14,TextColor3=C.text,AutoButtonColor=false,Visible=false,ZIndex=5,Parent=gui})
        local s=stroke(b,ACC,1.5,0); T(s,"Color"); return b
    end
    local upB,dnB=mkBtn("UP",-30),mkBtn("DN",30)
    local function hold(b,key)
        b.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then fly[key]=true end end)
        b.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then fly[key]=false end end)
    end
    hold(upB,"up"); hold(dnB,"dn")
    local spin={}
    local function spinClear(hum) for _,k in ipairs({"av","att"}) do if spin[k] then pcall(function() spin[k]:Destroy() end); spin[k]=nil end end if hum and spin.was then hum.AutoRotate=true end spin.was=false end
    local lastSafe,speedWas,jumpWas,ncTouched=nil,false,false,{}
    function X.charStep(dt,t,ch,hrp,hum)
        if Flags.speedOn then hum.WalkSpeed=Flags.speed; speedWas=true elseif speedWas then hum.WalkSpeed=16; speedWas=false end
        if Flags.jumpOn then hum.UseJumpPower=true; hum.JumpPower=Flags.jump; jumpWas=true elseif jumpWas then hum.JumpPower=50; jumpWas=false end
        if not Flags.fly and hum.FloorMaterial~=Enum.Material.Air then lastSafe=hrp.CFrame end
        if (Flags.fly or Flags.noclip or X.farmActive) and lastSafe and hrp.Position.Y<Workspace.FallenPartsDestroyHeight+80 then hrp.AssemblyLinearVelocity=Vector3.zero; hrp.CFrame=lastSafe+Vector3.new(0,4,0) end
        local cam=Workspace.CurrentCamera
        if Flags.fly then
            if not fly.on or not fly.lv or fly.lv.Parent~=hrp then flyStart(hrp,hum) end
            local cf,d=cam.CFrame,Vector3.zero
            if not UIS:GetFocusedTextBox() then
                if UIS:IsKeyDown(Enum.KeyCode.W) then d+=cf.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then d-=cf.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then d+=cf.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then d-=cf.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) or UIS:IsKeyDown(Enum.KeyCode.E) then d+=Vector3.yAxis end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.Q) then d-=Vector3.yAxis end
            end
            local md=hum.MoveDirection
            if d.Magnitude==0 and md.Magnitude>0.05 then d+=md end
            if fly.up then d+=Vector3.yAxis end
            if fly.dn then d-=Vector3.yAxis end
            fly.vel=fly.vel:Lerp(d.Magnitude>0 and d.Unit*Flags.flySpeed or Vector3.zero,1-math.exp(-10*dt))
            fly.lv.VectorVelocity=fly.vel
            fly.ao.Enabled=not Flags.spin
            local look=Vector3.new(cf.LookVector.X,0,cf.LookVector.Z); if look.Magnitude>0.01 then fly.ao.CFrame=CFrame.lookAt(Vector3.zero,look) end
            upB.Visible,dnB.Visible=UIS.TouchEnabled,UIS.TouchEnabled
        elseif fly.on or fly.lv then flyStop(hum); upB.Visible,dnB.Visible=false,false end
        if Flags.spin then
            if not spin.av or spin.av.Parent~=hrp then
                spinClear(nil)
                spin.att=new("Attachment",{Name="LxSpinA",Parent=hrp})
                spin.av=new("AngularVelocity",{Attachment0=spin.att,MaxTorque=math.huge,RelativeTo=Enum.ActuatorRelativeTo.World,Parent=hrp})
            end
            hum.AutoRotate=false; spin.was=true
            spin.av.AngularVelocity=Vector3.new(0,Flags.spinSpeed*0.08*(Flags.spinReverse and -1 or 1),0)
        elseif spin.av then spinClear(hum) end
    end
    track(RunService.Stepped:Connect(function()
        local ch=LP.Character
        if (Flags.noclip or X.farmNoclip) and ch then for _,p in ipairs(ch:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then ncTouched[p]=true; p.CanCollide=false end end
        elseif next(ncTouched) then for p in pairs(ncTouched) do if p.Parent and (p.Name=="HumanoidRootPart" or p.Name=="Torso" or p.Name=="UpperTorso" or p.Name=="LowerTorso" or p.Name=="Head") then p.CanCollide=true end end ncTouched={} end
    end))
    track(UIS.JumpRequest:Connect(function() if Flags.infJump then local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid"); if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end end end))
    function X.charReset() local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid"); flyStop(hum); spinClear(hum); if hum then hum.WalkSpeed=16; hum.PlatformStand=false; hum.AutoRotate=true end upB.Visible,dnB.Visible=false,false end
end

-- ===== COSMETICS: wings / hat / trail =====
do
    local Cos={}
    local function destroyCos(n) if Cos[n] then for _,o in ipairs(Cos[n].objs) do pcall(function() o:Destroy() end) end Cos[n]=nil end end
    X.destroyCos=destroyCos
    local function triDesc(a,b,c,th)
        if (b-a):Cross(c-a).Magnitude<1e-3 then return nil end
        local ab,ac,bc=b-a,c-a,c-b; local abd,acd,bcd=ab:Dot(ab),ac:Dot(ac),bc:Dot(bc)
        if abd>acd and abd>bcd then c,a=a,c elseif acd>bcd and acd>abd then a,b=b,a end
        ab,ac,bc=b-a,c-a,c-b
        local right=ac:Cross(ab).Unit; local up=bc:Cross(right).Unit; local back=bc.Unit; local height=math.max(0.05,math.abs(ab:Dot(up)))
        return {{Vector3.new(th,height,math.max(0.05,math.abs(ab:Dot(back)))),CFrame.fromMatrix((a+b)/2,right,up,back)},{Vector3.new(th,height,math.max(0.05,math.abs(ac:Dot(back)))),CFrame.fromMatrix((a+c)/2,-right,up,-back)}}
    end
    local function wpart(model,pivot,cls,size,cf,col,mat,list,mix)
        local p=Instance.new(cls); p.Size,p.Color,p.Material=size,col,mat
        p.CanCollide,p.CanQuery,p.CanTouch,p.Massless,p.CastShadow=false,false,false,true,false
        local w=Instance.new("Weld"); w.Part0,w.Part1,w.C0=pivot,p,cf; w.Parent=p; p.Parent=model
        if list then list[#list+1]={p,mix,col} end
        return p
    end
    local function mkPivot(model,torso,c0)
        local pv=Instance.new("Part"); pv.Size=Vector3.new(0.2,0.2,0.2); pv.Transparency=1; pv.CanCollide,pv.CanQuery,pv.CanTouch,pv.Massless=false,false,false,true
        local w=Instance.new("Weld"); w.Part0,w.Part1,w.C0=torso,pv,c0; w.Parent=pv; pv.Parent=model
        return pv,w
    end
    function X.buildWings()
        destroyCos("wings")
        local ch=LP.Character; local torso=ch and (ch:FindFirstChild("UpperTorso") or ch:FindFirstChild("Torso")); if not torso then return end
        local model=Instance.new("Model"); model.Name="luxxsWings"
        local sc=Flags.wingSize/100; local demon=Flags.wingStyle=="Demon"
        local W={model=model,pivots={},parts={},demon=demon}
        for _,side in ipairs({-1,1}) do
            if not demon then
                local rows={{n=7,a0=4,a1=78,lens={5.6,5.9,5.6,5.1,4.5,3.9,3.3},wid=0.62,mix=0.7,z=0},{n=7,a0=14,a1=104,lens={4.2,4.4,4.1,3.7,3.2,2.8,2.4},wid=0.7,mix=0.45,z=0.045},{n=6,a0=26,a1=116,lens={2.8,2.7,2.4,2.1,1.8,1.5},wid=0.78,mix=0.2,z=0.09}}
                for ri,row in ipairs(rows) do
                    local pv,w=mkPivot(model,torso,CFrame.new(side*0.35,0.5,0.5)); W.pivots[#W.pivots+1]={w=w,side=side,lag=(ri-1)*0.22}
                    for i=1,row.n do
                        local th=math.rad(row.a0+(row.a1-row.a0)*(i-1)/(row.n-1)); local d=Vector3.new(side*math.cos(th),math.sin(th),0); local nrm=Vector3.new(-d.Y,d.X,0)
                        local len,wid=row.lens[i]*sc,row.wid*sc; local b=len*0.62; local z=Vector3.new(0,0,row.z)
                        wpart(model,pv,"Part",Vector3.new(b,wid,0.04),CFrame.fromMatrix(d*(b/2)+z,d,nrm),WHITE,Enum.Material.SmoothPlastic,W.parts,row.mix*0.5)
                        local tri=triDesc(d*b+nrm*(wid/2)+z,d*b-nrm*(wid/2)+z,d*len+z,0.04)
                        if tri then for _,td in ipairs(tri) do wpart(model,pv,"WedgePart",td[1],td[2],WHITE,Enum.Material.Neon,W.parts,row.mix) end end
                    end
                end
            else
                local pv,w=mkPivot(model,torso,CFrame.new(side*0.35,0.5,0.5)); W.pivots[#W.pivots+1]={w=w,side=side,lag=0}
                local function P(x,y) return Vector3.new(side*x*sc,y*sc,0) end
                local E,Wr=P(1.5,1.9),P(3.3,3.0); local tips={P(4.6,5.8),P(6.4,4.4),P(6.8,2.1),P(5.5,0.1),P(3.4,-1.5)}; local B,O=P(0.4,-1.8),P(0,0)
                local dark=Color3.fromRGB(34,5,10)
                local function bone(a,b,th) wpart(model,pv,"Part",Vector3.new(th,th,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),dark,Enum.Material.SmoothPlastic,W.parts,0.5) end
                local function memb(a,b,c) local tri=triDesc(a,b,c,0.05); if tri then for _,td in ipairs(tri) do wpart(model,pv,"WedgePart",td[1],td[2],dark,Enum.Material.SmoothPlastic,W.parts,0.28) end end end
                bone(O,E,0.24); bone(E,Wr,0.2)
                for i,tp in ipairs(tips) do bone(Wr,tp,0.14-i*0.008); local cl=wpart(model,pv,"Part",Vector3.new(0.2,0.2,0.2),CFrame.new(tp),WHITE,Enum.Material.Neon,W.parts,1); cl.Shape=Enum.PartType.Ball end
                for i=1,#tips-1 do memb(Wr,tips[i],tips[i+1]) end
                memb(Wr,tips[#tips],B); memb(O,Wr,B)
            end
        end
        model.Parent=ch; Cos.wings=W; Cos.wings.objs={model}; Cos.wings.char=ch
    end
    function X.buildHat()
        destroyCos("hat")
        local ch=LP.Character; local head=ch and ch:FindFirstChild("Head"); if not head then return end
        local model=Instance.new("Model"); model.Name="luxxsHat"; local parts={}
        local function add(size,cf,shape,mat) local p=Instance.new("Part"); p.Size=size; p.CanCollide,p.CanQuery,p.CanTouch,p.Massless,p.CastShadow=false,false,false,true,false; p.Material=mat or Enum.Material.SmoothPlastic; if shape then p.Shape=shape end
            local w=Instance.new("Weld"); w.Part0,w.Part1,w.C0=head,p,cf; w.Parent=p; p.Parent=model; parts[#parts+1]=p end
        local style=Flags.hatStyle
        if style=="Chinese" then
            for i=1,10 do local r=2.0*(1-(i-1)/10)+0.1; add(Vector3.new(0.2,r*2,r*2),CFrame.new(0,0.55+(i-1)*0.19,0)*CFrame.Angles(0,0,math.pi/2),Enum.PartType.Cylinder) end
        elseif style=="Halo" then
            for i=1,22 do local a=i/22*math.pi*2; add(Vector3.new(0.14,0.09,0.34),CFrame.new(math.cos(a)*1.05,1.3,math.sin(a)*1.05)*CFrame.Angles(0,-a,0),nil,Enum.Material.Neon) end
        else
            for i=1,16 do local a=i/16*math.pi*2; add(Vector3.new(0.34,0.22,0.2),CFrame.new(math.cos(a)*0.95,0.75,math.sin(a)*0.95)*CFrame.Angles(0,-a,0),nil,Enum.Material.Metal) end
            for i=1,8 do local a=i/8*math.pi*2; add(Vector3.new(0.2,i%2==0 and 0.7 or 0.5,0.2),CFrame.new(math.cos(a)*0.95,1.15,math.sin(a)*0.95),nil,Enum.Material.Neon) end
        end
        model.Parent=ch; Cos.hat={objs={model},model=model,parts=parts}
    end
    function X.buildTrail()
        destroyCos("trail")
        local ch=LP.Character; local hrp=ch and ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local a0=new("Attachment",{Name="luxxsA0",Parent=hrp}); local a1=new("Attachment",{Name="luxxsA1",Parent=hrp})
        local tr=new("Trail",{Attachment0=a0,Attachment1=a1,LightEmission=1,FaceCamera=true,Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.1),NumberSequenceKeypoint.new(1,1)}),Parent=hrp})
        Cos.trail={objs={a0,a1,tr},a0=a0,a1=a1,trail=tr}
    end
    local acc=0
    function X.cosStep(dt,t,ch)
        local W=Cos.wings
        if Flags.wings and (not W or W.model.Parent~=ch) then X.buildWings() W=Cos.wings elseif not Flags.wings and W then destroyCos("wings") W=nil end
        if W then
            local sp=Flags.wingSpeed
            for _,pvt in ipairs(W.pivots) do pvt.w.C0=CFrame.new(pvt.side*0.35,0.5,0.5)*CFrame.Angles(0,-pvt.side*math.rad(24+math.sin(t*sp-pvt.lag*3)*16),0) end
        end
        local H_=Cos.hat
        if Flags.hat and (not H_ or H_.model.Parent~=ch) then X.buildHat() H_=Cos.hat elseif not Flags.hat and H_ then destroyCos("hat") H_=nil end
        local T_=Cos.trail
        if Flags.trail and (not T_ or not T_.trail.Parent) then X.buildTrail() T_=Cos.trail elseif not Flags.trail and T_ then destroyCos("trail") T_=nil end
        acc+=dt
        if acc>0.08 then
            acc=0
            if W then local tint=colorOf(Flags.wingCol,t); local base=W.demon and Color3.fromRGB(34,5,10) or WHITE
                for _,e in ipairs(W.parts) do if e[1].Parent then e[1].Color=((W.demon or e[2]>=1) and e[3] or base):Lerp(tint,e[2]) end end end
            if H_ then for i,p in ipairs(H_.parts) do p.Color=colorOf(Flags.hatCol,t,i*0.05) end end
        end
        if T_ and T_.trail.Parent then
            local w=Flags.trailWidth*0.4; T_.a0.Position=Vector3.new(0,w/2,0); T_.a1.Position=Vector3.new(0,-w/2,0)
            T_.trail.Lifetime=math.max(0.1,Flags.trailLen/10)
            local c=Flags.trailCol
            if c.rb then local kp={} for k=0,6 do kp[#kp+1]=ColorSequenceKeypoint.new(k/6,colorOf(c,t,-k/6*0.8)) end T_.trail.Color=ColorSequence.new(kp) else T_.trail.Color=ColorSequence.new(colorOf(c,t)) end
        end
    end
    function X.cosRespawn() destroyCos("wings"); destroyCos("hat"); destroyCos("trail") end
end

-- ===== SKIN CHANGER (client side only: only you see it) =====
do
    local SKINS={
        Chroma={rainbow=true,m=Enum.Material.Neon,r=0},
        Iceflake={c=Color3.fromRGB(150,225,255),m=Enum.Material.Ice,r=0.2},
        Candleflame={c=Color3.fromRGB(255,140,30),m=Enum.Material.Neon,r=0},
        Eternal={c=Color3.fromRGB(255,196,70),m=Enum.Material.Metal,r=0.35},
        Swirly={c=Color3.fromRGB(255,110,200),m=Enum.Material.Neon,r=0},
        Gemstone={c=Color3.fromRGB(70,255,220),m=Enum.Material.Glass,r=0.15},
        Lava={c=Color3.fromRGB(255,70,20),m=Enum.Material.Neon,r=0},
        Void={c=Color3.fromRGB(70,20,130),m=Enum.Material.Glass,r=0.1},
        Toxic={c=Color3.fromRGB(90,255,90),m=Enum.Material.Neon,r=0},
        Obsidian={c=Color3.fromRGB(18,18,24),m=Enum.Material.Glass,r=0.25},
    }
    function X.skinColor(name,t) local s=SKINS[name]; if not s then return WHITE end return s.rainbow and Color3.fromHSV((t*0.25)%1,0.85,1) or s.c end
    X.SKIN_DATA=SKINS
    local function keys(str) local out={} for k in string.gmatch(string.lower(str or ""),"[^,%s]+") do out[#out+1]=k end return out end
    local store=setmetatable({},{__mode="k"})
    local function texId(s) if not s or s=="" then return nil end local n=tonumber(s); return n and ("rbxassetid://"..n) or s end
    local function skinPart(part,name,tex,t)
        local o=store[part]
        if not o then local sm=part:FindFirstChildOfClass("SpecialMesh"); o={part.Color,part.Material,part.Reflectance,part:IsA("MeshPart") and part.TextureID or nil,sm,sm and sm.TextureId}; store[part]=o end
        local s=SKINS[name]; local custom=texId(tex)
        if not s and not custom then part.Color,part.Material,part.Reflectance=o[1],o[2],o[3]; if o[4]~=nil then part.TextureID=o[4] end if o[5] then o[5].TextureId=o[6] end return end
        if s then part.Color,part.Material,part.Reflectance=X.skinColor(name,t),s.m,s.r end
        if Flags.skinStrip and not custom then if part:IsA("MeshPart") then part.TextureID="" end if o[5] then o[5].TextureId="" end end
        if custom then if part:IsA("MeshPart") then part.TextureID=custom end if o[5] then o[5].TextureId=custom end end
    end
    local function fxFor(handle,name,kind,t)
        local em,tr=handle:FindFirstChild("LxSkinFx"),handle:FindFirstChild("LxSkinTrail"); local on=SKINS[name]~=nil
        if on and Flags.skinFx then
            if not em then em=new("ParticleEmitter",{Name="LxSkinFx",Rate=22,Lifetime=NumberRange.new(0.4,0.8),Speed=NumberRange.new(0.3,1.2),SpreadAngle=Vector2.new(180,180),LightEmission=1,Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.25),NumberSequenceKeypoint.new(1,0)}),Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.2),NumberSequenceKeypoint.new(1,1)}),Parent=handle}) end
            em.Color=ColorSequence.new(X.skinColor(name,t))
        elseif em then em:Destroy() end
        if on and Flags.skinTrail and kind=="knife" then
            if not tr then
                local sz=handle.Size; local ax=(sz.X>=sz.Y and sz.X>=sz.Z) and Vector3.xAxis or ((sz.Y>=sz.Z) and Vector3.yAxis or Vector3.zAxis); local half=math.max(sz.X,sz.Y,sz.Z)/2
                local a0=new("Attachment",{Name="LxSA0",Position=ax*half,Parent=handle}); local a1=new("Attachment",{Name="LxSA1",Position=-ax*half,Parent=handle})
                tr=new("Trail",{Name="LxSkinTrail",Attachment0=a0,Attachment1=a1,LightEmission=1,Lifetime=0.25,FaceCamera=true,Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.1),NumberSequenceKeypoint.new(1,1)}),Parent=handle})
            end
            tr.Color=ColorSequence.new(X.skinColor(name,t))
        elseif tr then local a0,a1=tr.Attachment0,tr.Attachment1; tr:Destroy(); if a0 then a0:Destroy() end if a1 then a1:Destroy() end end
    end
    local tick_=0
    X.skinVer=0
    local seen=0
    function X.skinStep(dt,t)
        tick_+=dt
        local rainbow=Flags.knifeSkin=="Chroma" or Flags.gunSkin=="Chroma"
        if tick_<(rainbow and 0.1 or 0.5) and seen==X.skinVer then return end
        tick_=0; seen=X.skinVer
        local kk,gk=keys(Flags.knifeKeys),keys(Flags.gunKeys); local targets={}
        local function kind(n) local l=string.lower(n); for _,k in ipairs(kk) do if l:find(k,1,true) then return "knife" end end for _,k in ipairs(gk) do if l:find(k,1,true) then return "gun" end end end
        local function scan(par,rec)
            if not par then return end
            for _,o in ipairs(par:GetChildren()) do
                if o:IsA("Tool") or o:IsA("Model") then local k=kind(o.Name); if k then targets[#targets+1]={o,k} elseif rec and o:IsA("Model") then scan(o,false) end end
            end
        end
        scan(LP.Character,false); scan(LP:FindFirstChildOfClass("Backpack"),false); scan(Workspace.CurrentCamera,true)
        for _,tg in ipairs(targets) do
            local name=tg[2]=="knife" and Flags.knifeSkin or Flags.gunSkin; local tex=tg[2]=="knife" and Flags.knifeTex or Flags.gunTex; local handle
            for _,d in ipairs(tg[1]:GetDescendants()) do if d:IsA("BasePart") then skinPart(d,name,tex,t); if not handle or d.Name=="Handle" then handle=d end end end
            if handle then fxFor(handle,name,tg[2],t) end
        end
    end
    function X.skinRestore()
        for part,o in pairs(store) do if part.Parent then part.Color,part.Material,part.Reflectance=o[1],o[2],o[3]; if o[4]~=nil then part.TextureID=o[4] end if o[5] then o[5].TextureId=o[6] end
            for _,n in ipairs({"LxSkinFx","LxSkinTrail","LxSA0","LxSA1"}) do local x=part:FindFirstChild(n); if x then x:Destroy() end end end end
    end
end

-- ===== SHADERS =====
do
    local Shader={}
    local PRESETS={
        Cinematic={b=0.02,c=0.25,s=-0.1,tint=Color3.fromRGB(255,238,220),bloom=0.5,bsize=28,bth=1,rays=0.08,dens=0.3,haze=1.2,acol=Color3.fromRGB(190,190,205)},
        ["Neon Night"]={b=-0.03,c=0.3,s=0.5,tint=Color3.fromRGB(215,190,255),bloom=1.3,bsize=42,bth=0.75,rays=0,dens=0.35,haze=1.5,acol=Color3.fromRGB(110,70,200)},
        Sunset={b=0.03,c=0.15,s=0.3,tint=Color3.fromRGB(255,205,160),bloom=0.6,bsize=30,bth=0.9,rays=0.25,dens=0.3,haze=1.8,acol=Color3.fromRGB(255,170,120)},
        Vivid={b=0.02,c=0.2,s=0.7,tint=WHITE,bloom=0.4,bsize=24,bth=1,rays=0.1,dens=0.2,haze=0.5,acol=Color3.fromRGB(200,215,235)},
        Noir={b=-0.02,c=0.4,s=-1,tint=Color3.fromRGB(235,235,245),bloom=0.3,bsize=20,bth=1,rays=0,dens=0.35,haze=2.2,acol=Color3.fromRGB(160,160,170)},
        Dream={b=0.05,c=-0.05,s=0.3,tint=Color3.fromRGB(255,210,255),bloom=1,bsize=50,bth=0.7,rays=0.15,dens=0.4,haze=1,acol=Color3.fromRGB(255,190,240)},
    }
    X.PRESET_NAMES={"Off","Cinematic","Neon Night","Sunset","Vivid","Noir","Dream"}
    local NEUTRAL={b=0,c=0,s=0,tint=WHITE,bloom=0,bsize=24,bth=1,rays=0}
    local function ensure()
        if Shader.cc then return end
        local function mk(c) local i=Instance.new(c); i.Name="luxxs_"..c; i.Parent=Lighting; return i end
        Shader.cc,Shader.bloom,Shader.rays=mk("ColorCorrectionEffect"),mk("BloomEffect"),mk("SunRaysEffect")
        local atm=Lighting:FindFirstChildOfClass("Atmosphere")
        if atm then Shader.atm=atm; Shader.atmOrig={Density=atm.Density,Haze=atm.Haze,Color=atm.Color} else Shader.atm=mk("Atmosphere"); Shader.atm.Density=0; Shader.atmCreated=true end
    end
    function X.disableShader(full)
        if not Shader.cc then return end
        Shader.cc.Enabled=false; Shader.bloom.Enabled=false; Shader.rays.Enabled=false
        if Shader.atmOrig then pcall(function() tween(Shader.atm,0.5,Shader.atmOrig) end) elseif Shader.atm then pcall(function() Shader.atm.Density=0 end) end
        if full then for _,k in ipairs({"cc","bloom","rays"}) do pcall(function() Shader[k]:Destroy() end) end if Shader.atmCreated then pcall(function() Shader.atm:Destroy() end) end Shader={} end
    end
    function X.refreshShader(time)
        time=time or 0.9
        local preset=PRESETS[Flags.shPreset or "Off"]
        local ob,oc,os_,obl=Flags.shBright/100,Flags.shContrast/100,Flags.shSat/100,Flags.shBloom/50
        if not preset and ob==0 and oc==0 and os_==0 and obl==0 then X.disableShader(false) return end
        ensure(); local p=preset or NEUTRAL
        Shader.cc.Enabled=true; Shader.bloom.Enabled=true; Shader.rays.Enabled=true
        tween(Shader.cc,time,{Brightness=p.b+ob,Contrast=p.c+oc,Saturation=p.s+os_,TintColor=p.tint})
        tween(Shader.bloom,time,{Intensity=p.bloom+obl,Size=p.bsize,Threshold=p.bth}); tween(Shader.rays,time,{Intensity=p.rays})
        if preset then tween(Shader.atm,time,{Density=preset.dens,Haze=preset.haze,Color=preset.acol}) elseif Shader.atmOrig then tween(Shader.atm,time,Shader.atmOrig) else tween(Shader.atm,time,{Density=0}) end
    end
end

-- ===== FPS COUNTER + CAP (the chosen cap is shown on the counter) =====
do
    local capfn do local ok,f=pcall(function() return setfpscap end); if ok and type(f)=="function" then capfn=f end end
    X.hasCap=capfn~=nil
    local fpsFrame=new("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-12,0,12),Size=UDim2.fromOffset(170,24),BackgroundColor3=C.bg,BackgroundTransparency=0.1,BorderSizePixel=0,Visible=false,ZIndex=5,Parent=fpsGui}); stroke(fpsFrame,C.line,1,0)
    local fb=new("Frame",{Size=UDim2.new(0,2,1,0),BorderSizePixel=0,ZIndex=6,Parent=fpsFrame}); T(fb,"BackgroundColor3")
    local fpsNum=new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(10,0),Size=UDim2.new(1,-12,1,0),Font=F_MONO,TextSize=12,TextColor3=C.text,TextXAlignment=Enum.TextXAlignment.Left,Text="0 FPS",ZIndex=6,Parent=fpsFrame})
    makeDraggable(fpsFrame,fpsFrame)
    X.fps={cur=0,avg=0,max=0,cap=0}
    local acc,cnt,lastCap=0,0,nil
    function X.applyCap() if capfn then local want=Flags.fpsOn and Flags.fpsTarget or nil; if want~=lastCap then lastCap=want; pcall(capfn,want or 60) end end X.fps.cap=Flags.fpsOn and Flags.fpsTarget or 0 end
    function X.fpsStep(dt)
        acc+=dt; cnt+=1
        if acc>=0.25 then
            local fps=math.floor(cnt/acc+0.5); acc,cnt=0,0
            X.fps.cur=fps; X.fps.avg=X.fps.avg==0 and fps or (X.fps.avg*0.9+fps*0.1); if fps>X.fps.max then X.fps.max=fps end
            fpsNum.Text=fps.." FPS"..(Flags.fpsOn and ("  |  cap "..Flags.fpsTarget..(capfn and "" or "*")) or "")
            fpsNum.TextColor3=fps>=60 and C.text or (fps>=30 and Color3.fromRGB(255,190,70) or C.red)
        end
        fpsFrame.Visible=(Flags.fpsShow and unlocked) and true or false
    end
    function X.fpsRestore() if capfn then pcall(capfn,60) end end
end

-- ===== COIN FARM (smooth fly / paced teleport, human-like pauses) =====
do
    local Farm={Collected=0,Status="idle"}
    X.Farm=Farm
    local coinSet,coinConns={}, {}
    local function isCoin(o) return o:IsA("BasePart") and (o.Name=="Coin" or o.Name:find("Coin") or o.Name:find("coin")) end
    local function startCache()
        for _,c in ipairs(coinConns) do c:Disconnect() end
        coinConns={}; coinSet={}
        for _,o in ipairs(Workspace:GetDescendants()) do if isCoin(o) then coinSet[o]=true end end
        coinConns[1]=Workspace.DescendantAdded:Connect(function(o) if isCoin(o) then coinSet[o]=true end end)
        coinConns[2]=Workspace.DescendantRemoving:Connect(function(o)
            if coinSet[o] then coinSet[o]=nil; local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"); if Flags.farm and hrp and (hrp.Position-o.Position).Magnitude<12 then Farm.Collected+=1 end end
        end)
    end
    local function nearest(pos,skip)
        local best,bd,now=nil,math.huge,os.clock()
        for p in pairs(coinSet) do if p.Parent and not (skip[p] and skip[p]>now) then local d=(p.Position-pos).Magnitude; if d<bd then best,bd=p,d end end end
        return best
    end
    local function rnd(a,b) return a+math.random()*(b-a) end
    local thread
    function X.startFarm()
        if thread then return end
        local hrp0=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"); local start=hrp0 and hrp0.CFrame
        X.farmActive=true; X.farmNoclip=Flags.farmMode=="Fly"
        thread=task.spawn(function()
            startCache(); local skip,sinceRest={}, 0
            while Flags.farm do
                local dt=RunService.Heartbeat:Wait()
                local ok,ch,hum,hrp=isAlive(LP)
                X.farmNoclip=Flags.farmMode=="Fly"
                if ok then
                    if Flags.farmLimit>0 and Farm.Collected>=Flags.farmLimit then Farm.Status="limit reached" task.wait(0.5)
                    else
                        local coin=nearest(hrp.Position,skip)
                        if coin then
                            Farm.Status="to coin"; local target=coin.Position
                            if Flags.farmMode=="Teleport" then
                                task.wait(rnd(Flags.farmDelayMin,Flags.farmDelayMax)/1000)
                                if coin.Parent then hrp.CFrame=CFrame.new(target); hrp.AssemblyLinearVelocity=Vector3.zero end
                                task.wait(rnd(0.12,0.3))
                            else
                                local spd=math.clamp(Flags.farmSpeed*rnd(0.88,1.12),10,120)
                                local d=target-hrp.Position
                                if d.Magnitude<=spd*dt then hrp.CFrame=CFrame.new(target) else hrp.CFrame=CFrame.new(hrp.Position+d.Unit*spd*dt) end
                                hrp.AssemblyLinearVelocity=Vector3.zero
                            end
                            if (hrp.Position-target).Magnitude<3 then skip[coin]=os.clock()+0.6; sinceRest+=1; task.wait(rnd(0.08,0.25))
                                if Flags.farmRest and sinceRest>=math.random(6,10) then sinceRest=0; Farm.Status="resting"; task.wait(rnd(1,2.5)) end
                            end
                        else Farm.Status="no coins"; task.wait(0.3) end
                    end
                end
            end
            if Flags.farmReturn and start then local _,_,_,hr=isAlive(LP); if hr then hr.CFrame=start end end
            Farm.Status="idle"; thread=nil
        end)
    end
    function X.stopFarm()
        X.farmActive=false; X.farmNoclip=false
        if thread then pcall(function() task.cancel(thread) end); thread=nil end
        for _,c in ipairs(coinConns) do c:Disconnect() end coinConns={}; Farm.Status="idle"
    end
end

-- ===== AUTO WIN (sheriff -> go to the murderer and shoot, murderer -> stab everyone) =====
do
    local AW={Status="idle"}
    X.AW=AW
    local function findTool(plr,pattern)
        for _,c in ipairs({plr.Character,plr:FindFirstChildOfClass("Backpack")}) do
            if c then for _,o in ipairs(c:GetChildren()) do if o:IsA("Tool") and string.lower(o.Name):find(pattern) then return o end end end
        end
        return nil
    end
    local function equip(tool,hum) if tool and tool.Parent~=LP.Character and hum then pcall(function() hum:EquipTool(tool) end) end end
    local function use(tool)
        pcall(function() tool:Activate() end)
        if firesignal then pcall(function() firesignal(tool.Activated) end) end
        pcall(function() VU:ClickButton1(Vector2.new(0,0)) end)
    end
    local function stand(hrp,targetHRP,dist)
        local pos=(targetHRP.CFrame*CFrame.new(0,0,dist)).Position
        hrp.CFrame=CFrame.lookAt(pos,targetHRP.Position); hrp.AssemblyLinearVelocity=Vector3.zero
    end
    local function aimAt(part) local cam=Workspace.CurrentCamera; if cam and part then cam.CFrame=CFrame.lookAt(cam.CFrame.Position,part.Position) end end
    local thread
    local function pause(ms) if ms<=0 then RunService.Heartbeat:Wait() else task.wait(ms/1000) end end
    function X.startAW()
        if thread then return end
        thread=task.spawn(function()
            while Flags.autoWin do
                local ok,ch,hum,hrp=isAlive(LP)
                if not ok then AW.Status="dead" task.wait(0.5)
                else
                    local mode=Flags.awMode; local role=getRoleCached(LP)
                    if mode=="Sheriff" then role="Sheriff" elseif mode=="Murderer" then role="Murderer" end
                    local home=hrp.CFrame
                    if role=="Sheriff" then
                        local gun=findTool(LP,"gun") or findTool(LP,"revolver")
                        local murd
                        for _,p in ipairs(plist) do if p~=LP and isAlive(p) and getRoleCached(p)=="Murderer" then murd=p break end end
                        if gun and murd then
                            AW.Status="hunting "..murd.Name; local t0=os.clock()
                            while Flags.autoWin and os.clock()-t0<Flags.awTimeout do
                                local a,_,_,thrp=isAlive(murd); local me,_,mh,mhrp=isAlive(LP)
                                if not a or not me then break end
                                stand(mhrp,thrp,Flags.awDist); equip(gun,mh); aimAt(murd.Character:FindFirstChild("Head") or thrp); use(gun); pause(Flags.awDelay)
                            end
                            if Flags.awReturn then local _,_,_,h2=isAlive(LP); if h2 then h2.CFrame=home end end
                        else AW.Status=gun and "no murderer" or "no gun"; task.wait(0.4) end
                    elseif role=="Murderer" then
                        local knife=findTool(LP,"knife")
                        if knife then
                            local list={}
                            for _,p in ipairs(plist) do if p~=LP and isAlive(p) then list[#list+1]=p end end
                            table.sort(list,function(a,b) local _,_,_,ra=isAlive(a); local _,_,_,rb=isAlive(b); return (ra.Position-hrp.Position).Magnitude<(rb.Position-hrp.Position).Magnitude end)
                            if #list==0 then AW.Status="nobody left"; task.wait(0.4) end
                            for _,victim in ipairs(list) do
                                if not Flags.autoWin then break end
                                AW.Status="killing "..victim.Name; local t0=os.clock()
                                while Flags.autoWin and os.clock()-t0<Flags.awTimeout do
                                    local a,_,_,thrp=isAlive(victim); local me,_,mh,mhrp=isAlive(LP)
                                    if not a or not me then break end
                                    stand(mhrp,thrp,math.min(Flags.awDist,3)); equip(knife,mh); aimAt(thrp); use(knife); pause(Flags.awDelay)
                                end
                            end
                            if Flags.awReturn then local _,_,_,h2=isAlive(LP); if h2 then h2.CFrame=home end end
                        else AW.Status="no knife"; task.wait(0.4) end
                    else AW.Status="innocent (waiting for role)"; task.wait(0.5) end
                end
                task.wait(0.05)
            end
            AW.Status="idle"; thread=nil
        end)
    end
    function X.stopAW() if thread then pcall(function() task.cancel(thread) end); thread=nil end AW.Status="idle" end
end

-- =====================================================================
-- TABS
-- =====================================================================
local SKIN_NAMES={"Off","Chroma","Iceflake","Candleflame","Eternal","Swirly","Gemstone","Lava","Void","Toxic","Obsidian"}
local AIM_PARTS={"Head","Chest","Stomach","Left Arm","Right Arm","Left Leg","Right Leg","Closest"}
local RAINBOW={h=0,s=0.85,v=1,rb=true}
local function bumpSkin() X.skinVer=X.skinVer+1 end

local aimTab=createTab("Aimbot")
aimTab:Label("Aim assist")
aimTab:Module("Aimbot","aim",false,nil,function(s)
    s:Choice("Activation","aimAct",{"Hold RMB","Always"},"Hold RMB")
    s:Choice("Mode","aimMode",{"Smooth","Snap"},"Smooth")
    s:Slider("Smoothness","aimSmooth",1,100,35,nil,function(v) return v.."%" end)
    s:Choice("Aim part","aimPart",AIM_PARTS,"Head")
    s:Slider("FOV radius","aimFov",30,600,150,nil,function(v) return v.."px" end)
    s:Toggle("Wall check","aimWall",true)
    s:Toggle("Smart target (by role)","aimSmart",true)
    s:Slider("Prediction","aimPredict",0,30,0,nil,function(v) return v.."%" end)
    s:Toggle("Show FOV circle","aimShowFov",false)
    s:Color("FOV color","aimFovCol",ACC)
end)
aimTab:Module("Silent Aim","silent",false,function(on) if on and Flags.silentMethod=="Hook" then X.installSilent() end end,function(s)
    s:Choice("Method","silentMethod",{"Hook","Flick"},"Hook",function(m) if m=="Hook" and Flags.silent then X.installSilent() end end)
    s:Slider("FOV radius","silentRadius",30,600,160,nil,function(v) return v.."px" end)
    s:Toggle("Show FOV circle","silentFov",false)
    s:Color("FOV color","silentCol",Color3.fromRGB(255,214,10))
    s:Choice("Hit part","silentPart",AIM_PARTS,"Head")
    s:Toggle("Wall check","silentWall",true)
    s:Toggle("Smart target (by role)","silentSmart",true)
    s:Slider("Hit chance","silentChance",1,100,100,nil,function(v) return v.."%" end)
    s:Slider("Prediction","silentPredict",0,30,0,nil,function(v) return v.."%" end)
    s:Toggle("Target marker","silentMark",true)
end)
aimTab:Note("Hook needs an executor with hookmetamethod. Without it Silent Aim falls back to Flick (the camera snaps to the target for 2 frames when you click).",52)
aimTab:Note("Click a dot on the mannequin in the preview to choose the aim part.",30)

local visTab=createTab("Visuals")
visTab:Label("ESP")
visTab:Module("Boxes","box",false,nil,function(s)
    s:Choice("Style","boxStyle",{"2D","3D"},"2D")
    s:Color("ESP color","espCol",ACC)
    s:Toggle("Color by role","colorByRole",false)
    s:Slider("Max distance","espDist",100,3000,1500,nil,function(v) return v.."m" end,50)
end)
visTab:Toggle("Role","role",false)
visTab:Toggle("Name","name",false)
visTab:Toggle("Health","hp",false)
visTab:Toggle("Distance","dist",false)
visTab:Toggle("Tracers","tracer",false)
visTab:Toggle("Skeleton","skel",false)
visTab:Label("Chams / Glow")
visTab:Module("Chams","chams",false,nil,function(s)
    s:Color("Fill color","chamCol",ACC)
    s:Slider("Fill transparency","chamTrans",0,95,45,nil,function(v) return v.."%" end)
    s:Toggle("Through walls","chamWalls",true)
    s:Toggle("Pulse","chamPulse",false)
end)
visTab:Module("Glow","glow",false,nil,function(s) s:Color("Outline color","glowCol",Color3.fromRGB(110,214,255)) end)
visTab:Module("Gun ESP","gunEsp",false,nil,function(s) s:Color("Gun color","gunCol",Color3.fromRGB(255,214,10)); s:Button("Teleport to gun",X.teleportToGun) end)
visTab:Label("Cosmetics")
visTab:Module("Wings","wings",false,nil,function(s)
    s:Choice("Style","wingStyle",{"Angel","Demon"},"Angel",function() if Flags.wings then X.buildWings() end end)
    s:Color("Color","wingCol",Color3.fromRGB(255,255,255))
    s:Slider("Flap speed","wingSpeed",1,10,3)
    s:Slider("Size","wingSize",60,160,100,function() if Flags.wings then X.buildWings() end end,function(v) return v.."%" end,5)
end)
visTab:Module("Hat","hat",false,nil,function(s)
    s:Choice("Style","hatStyle",{"Chinese","Halo","Crown"},"Chinese",function() if Flags.hat then X.buildHat() end end)
    s:Color("Color","hatCol",RAINBOW)
end)
visTab:Module("Trail","trail",false,nil,function(s)
    s:Color("Color","trailCol",RAINBOW)
    s:Slider("Length","trailLen",1,30,10)
    s:Slider("Width","trailWidth",1,10,4)
end)

local charTab=createTab("Character")
charTab:Label("Movement")
charTab:Module("Fly","fly",false,nil,function(s) s:Slider("Fly speed","flySpeed",10,300,60); s:Note("PC: WASD + Space/E up, Ctrl/Q down. Mobile: joystick + UP/DN buttons.",30) end)
charTab:Toggle("Noclip","noclip",false)
charTab:Module("Spin","spin",false,nil,function(s) s:Slider("Spin speed","spinSpeed",1,1000,500); s:Toggle("Reverse","spinReverse",false) end)
charTab:Module("Walk speed","speedOn",false,nil,function(s) s:Slider("Speed","speed",16,150,32) end)
charTab:Module("Jump power","jumpOn",false,nil,function(s) s:Slider("Jump","jump",50,300,100) end)
charTab:Toggle("Infinite jump","infJump",false)

local autoTab=createTab("Auto")
autoTab:Label("Automation")
autoTab:Module("Auto Win","autoWin",false,function(on) if on then X.startAW() else X.stopAW() end end,function(s)
    s:Choice("Role","awMode",{"Auto","Sheriff","Murderer"},"Auto")
    s:Slider("Delay between hits","awDelay",0,500,90,nil,function(v) return v.."ms" end)
    s:Slider("Distance","awDist",2,10,4)
    s:Slider("Timeout per target","awTimeout",2,30,10,nil,function(v) return v.."s" end)
    s:Toggle("Return to start","awReturn",true)
    s:Note("Sheriff: goes to the murderer and shoots. Murderer: goes to every player and stabs. Uses your equipped tool (Activate), so it depends on how your game validates hits.",64)
end)
autoTab:Module("Coin Farm","farm",false,function(on) if on then X.startFarm() else X.stopFarm() end end,function(s)
    s:Choice("Mode","farmMode",{"Fly","Teleport"},"Fly")
    s:Slider("Fly speed","farmSpeed",10,120,45)
    s:Slider("Teleport delay min","farmDelayMin",100,2000,450,nil,function(v) return v.."ms" end,10)
    s:Slider("Teleport delay max","farmDelayMax",200,3000,1000,nil,function(v) return v.."ms" end,10)
    s:Toggle("Rest pauses","farmRest",true)
    s:Slider("Coin limit (0 = none)","farmLimit",0,100,0)
    s:Toggle("Return to start","farmReturn",false)
    s:Button("Reset counter",function() X.Farm.Collected=0; notify("Counter reset") end)
    s:Note("Speed is capped, delays are randomised and it pauses now and then, but no script can promise it will never be flagged.",52)
end)
autoTab:Toggle("Anti-AFK","antiAfk",false,function(on)
    if X.afkConn then X.afkConn:Disconnect(); X.afkConn=nil end
    if on then X.afkConn=LP.Idled:Connect(function() VU:CaptureController(); VU:ClickButton2(Vector2.new()) end) end
end)
autoTab:Button("Teleport to gun",X.teleportToGun)

local skinTab=createTab("Skins")
skinTab:Label("Knife")
skinTab:Choice("Knife skin","knifeSkin",SKIN_NAMES,"Off",bumpSkin)
skinTab:Input("Knife texture ID","knifeTex","",bumpSkin)
skinTab:Label("Gun")
skinTab:Choice("Gun skin","gunSkin",SKIN_NAMES,"Off",bumpSkin)
skinTab:Input("Gun texture ID","gunTex","",bumpSkin)
skinTab:Label("Options")
skinTab:Toggle("Particles","skinFx",false,bumpSkin)
skinTab:Toggle("Knife trail","skinTrail",false,bumpSkin)
skinTab:Toggle("Strip textures","skinStrip",false,bumpSkin)
skinTab:Input("Knife name keywords","knifeKeys","knife",bumpSkin)
skinTab:Input("Gun name keywords","gunKeys","gun,revolver",bumpSkin)
skinTab:Note("Skins are visual and client-side: only you see them. They recolor and re-material the knife/gun found by name in your hands, backpack or view model; the exact MM2 models can't be recreated here, so the names are colorways (Chroma, Iceflake, Candleflame...).",78)

local shTab=createTab("Shaders")
shTab:Label("Look")
shTab:Choice("Preset","shPreset",X.PRESET_NAMES,"Off",function() X.refreshShader(0.9) end)
shTab:Slider("Brightness","shBright",-50,50,0,function() X.refreshShader(0.15) end)
shTab:Slider("Contrast","shContrast",-50,50,0,function() X.refreshShader(0.15) end)
shTab:Slider("Saturation","shSat",-100,100,0,function() X.refreshShader(0.15) end)
shTab:Slider("Bloom","shBloom",0,100,0,function() X.refreshShader(0.15) end)
shTab:Button("Reset shaders",function() Setters.shPreset("Off"); Setters.shBright(0); Setters.shContrast(0); Setters.shSat(0); Setters.shBloom(0) end)

local fpsTab=createTab("FPS")
fpsTab:Label("Unlocker")
fpsTab:Module("Custom FPS","fpsOn",false,function() X.applyCap() end,function(s)
    s:Slider("Target FPS","fpsTarget",30,10000,240,function() X.applyCap() end)
    s:Input("Type FPS","fpsType","999",function(txt,tb) local n=tonumber(txt); if n then Setters.fpsTarget(math.clamp(math.floor(n),30,10000)); Setters.fpsOn(true) else notify("Invalid FPS") end end)
    s:Button("60 FPS",function() Setters.fpsTarget(60) end); s:Button("144 FPS",function() Setters.fpsTarget(144) end); s:Button("240 FPS",function() Setters.fpsTarget(240) end); s:Button("999 FPS",function() Setters.fpsTarget(999) end)
end)
fpsTab:Toggle("Show counter","fpsShow",true)
fpsTab:Button("Reset stats",function() X.fps.max=0; X.fps.avg=0; notify("FPS stats reset") end)
fpsTab:Label("Optimization")
fpsTab:Toggle("Remove shadows","noShadows",false,function(s) Lighting.GlobalShadows=not s end)
fpsTab:Toggle("Remove fog","noFog",false,function(s) Lighting.FogEnd=s and 1e6 or 100000 end)
fpsTab:Toggle("Remove effects","noEffects",false,function(s) for _,e in ipairs(Lighting:GetChildren()) do if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then if not e.Name:find("luxxs") then e.Enabled=not s end end end end)
if not X.hasCap then fpsTab:Note("setfpscap not found: the cap is shown on the counter (marked *) but the engine limit can't change here.",40) end

-- ===== PROFILE (avatar of the player's skin) =====
local profTab=createTab("Profile")
local prof={view=LP,labels={}}
profTab:Label("Player")
local avFrame=profTab:Custom(150)
local avBox=new("Frame",{Position=UDim2.fromOffset(6,4),Size=UDim2.fromOffset(140,140),BackgroundColor3=C.row,BorderSizePixel=0,ClipsDescendants=true,Parent=avFrame}); stroke(avBox,C.line,1,0); cornerTick(avBox,0,0,1,1,10,5); cornerTick(avBox,140,140,-1,-1,10,5)
local avImg=new("ImageLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Image="",ScaleType=Enum.ScaleType.Fit,Parent=avBox})
local avName=new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(152,6),Size=UDim2.new(1,-156,0,22),Font=F_HEAD,TextSize=13,TextColor3=C.text,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Text=LP.Name,Parent=avFrame})
local avSub=new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(152,30),Size=UDim2.new(1,-156,0,16),Font=F_MONO,TextSize=10,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Text="",Parent=avFrame})
local function loadAvatar()
    local p=prof.view; if not p then return end
    task.spawn(function()
        local ok,img=pcall(function() return (Players:GetUserThumbnailAsync(p.UserId,Enum.ThumbnailType[Flags.avatarKind],Enum.ThumbnailSize.Size420x420)) end)
        if ok and avImg.Parent then avImg.Image=img end
    end)
    avName.Text=p.DisplayName; avSub.Text="@"..p.Name
end
profTab:Choice("Avatar view","avatarKind",{"AvatarBust","HeadShot","AvatarThumbnail"},"AvatarBust",loadAvatar)
profTab:Input("View player","viewName","",function(txt)
    local q=string.lower(txt or ""); local found=LP
    if q~="" then found=nil; for _,p in ipairs(Players:GetPlayers()) do local n,d=string.lower(p.Name),string.lower(p.DisplayName); if n==q or d==q or n:find(q,1,true) or d:find(q,1,true) then found=p break end end end
    if found then prof.view=found; loadAvatar(); notify("Profile: "..found.Name) else notify("Player not found") end
end)
profTab:Label("Stats")
for _,k in ipairs({"user","id","age","role","team","ping","session","coins","fps","farm","aw"}) do prof.labels[k]=profTab:Note("",16); prof.labels[k].TextSize=11 end
profTab:Button("Copy user id",function() if setclipboard then setclipboard(tostring(prof.view.UserId)); notify("User id copied") else notify("Clipboard unavailable") end end)
profTab:Button("Reset stats",function() X.fps.max=0; X.fps.avg=0; X.Farm.Collected=0; notify("Stats reset") end)

-- ===== SETTINGS =====
local setTab=createTab("Settings")
local SLOTS={"1","2","3","4","5"}
local EXCLUDE={slot=true,menuAlpha=true,menuSize=true,accentName=true,customAccent=true,viewName=true,avatarKind=true}
local function cfgPath(s) return FOLDER.."/config_"..s..".json" end
setTab:Label("Interface")
setTab:Choice("Accent","accentName",ACCENT_NAMES,ACC_NAME,function(n) setAccent(ACCENTS[n]); restyleTabs(); if hasFS then ensureFolder(); pcall(function() writefile(FOLDER.."/accent.txt",n) end) end end)
setTab:Color("Custom accent","customAccent",ACC,function(c) setAccent(colorOf(c,os.clock())); restyleTabs() end)
setTab:Slider("Menu transparency","menuAlpha",0,70,0,function(v) G.alpha=v/100; applyAlpha() end,function(v) return v.."%" end)
setTab:Slider("Menu size","menuSize",60,120,100,function(v) G.size=v/100; refit() end,function(v) return v.."%" end,5)
setTab:Label("Configs")
setTab:Choice("Config slot","slot",SLOTS,"1")
setTab:Button("Save config",function()
    if not hasFS then notify("File system not available") return end
    ensureFolder(); local data={}
    for k,v in pairs(Flags) do if not EXCLUDE[k] then data[k]=v end end
    notify(pcall(function() writefile(cfgPath(Flags.slot),HttpService:JSONEncode(data)) end) and ("Config saved: slot "..Flags.slot) or "Save error")
end)
setTab:Button("Load config",function()
    if not hasFS or not isfile(cfgPath(Flags.slot)) then notify("Slot empty") return end
    local ok,data=pcall(function() return HttpService:JSONDecode(readfile(cfgPath(Flags.slot))) end)
    if not ok or type(data)~="table" then notify("Read error") return end
    for k,v in pairs(data) do if Setters[k] and not EXCLUDE[k] then Setters[k](v) end end
    notify("Config loaded: slot "..Flags.slot)
end)
setTab:Toggle("Autoload","autoload",false,function(s) if hasFS then ensureFolder(); pcall(function() writefile(FOLDER.."/autoload.txt",s and Flags.slot or "") end) end end)
setTab:Button("Reset all",function() for k,d in pairs(Defaults) do if Setters[k] and not EXCLUDE[k] and k~="slot" then Setters[k](type(d)=="table" and copyColor(d) or d) end end notify("Settings reset") end)
setTab:Label("Menu")
setTab:Button("Close menu",closeMenu)
local unload
setTab:Button("Unload luxxs",function() unload() end)

-- =====================================================================
-- PREVIEW (round mannequin, no neck)
-- =====================================================================
local function buildPreview()
    local PW,PH=252,372; local panel=previewPanel
    local function solid(p,x,y,w,h,color,z,r) local f=new("Frame",{Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundColor3=color,BorderSizePixel=0,ZIndex=z or 1,Parent=p}); if r and r>0 then corner(f,r) end return f end
    local function lineF(p,x1,y1,x2,y2,th,col,z) local f=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=col,BorderSizePixel=0,ZIndex=z or 1,Parent=p}); setLine(f,x1,y1,x2,y2,th,col); return f end
    panel.BackgroundColor3=WHITE; panel.ClipsDescendants=true; BG(panel,0)
    gradient(panel,90,ColorSequence.new(Color3.fromRGB(21,25,22),Color3.fromRGB(8,10,9))); stroke(panel,C.line,1,0)
    for i,y in ipairs({308,318,331,348,370}) do local f=solid(panel,0,y,PW,1,WHITE,1); f.BackgroundTransparency=0.9-i*0.02; T(f,"BackgroundColor3") end
    for i=-5,5 do local l=lineF(panel,126+i*6,300,126+i*44,372,1,WHITE,1); l.BackgroundTransparency=0.9; T(l,"BackgroundColor3") end
    local scanBand=solid(panel,0,0,PW,38,WHITE,2); T(scanBand,"BackgroundColor3"); gradient(scanBand,90,nil,NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0.8)}))
    local scanLine=solid(panel,0,0,PW,1,WHITE,2); scanLine.BackgroundTransparency=0.3; T(scanLine,"BackgroundColor3")
    cornerTick(panel,0,0,1,1,10,8); cornerTick(panel,PW,0,-1,1,10,8); cornerTick(panel,0,PH,1,-1,10,8); cornerTick(panel,PW,PH,-1,-1,10,8)
    local liveDot=solid(panel,12,10,5,5,WHITE,9); T(liveDot,"BackgroundColor3")
    new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(24,3),Size=UDim2.fromOffset(100,18),Font=F_MONO,TextSize=10,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Left,Text="PREVIEW // LIVE",ZIndex=9,Parent=panel})
    local aimCap=new("TextLabel",{BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-12,0,3),Size=UDim2.fromOffset(130,18),Font=F_MONO,TextSize=10,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=9,Parent=panel}); T(aimCap,"TextColor3")
    solid(panel,0,23,PW,1,C.line,3)
    local strip=solid(panel,0,PH-26,PW,26,Color3.fromRGB(11,13,12),8); strip.BackgroundTransparency=0.05; solid(panel,0,PH-26,PW,1,C.line,9)
    local tagsL=new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(10,PH-26),Size=UDim2.new(1,-20,0,26),Font=F_MONO,TextSize=10,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Text="NO MODULES",ZIndex=10,Parent=panel})
    local glow={}
    for i=1,4 do local s=230-i*40; local c=solid(panel,0,0,s,s,WHITE,1,9999); c.AnchorPoint=Vector2.new(0.5,0.5); c.Position=UDim2.fromOffset(126,200); c.BackgroundTransparency=0.95; glow[i]=c end
    local shadow=solid(panel,0,0,120,22,Color3.new(0,0,0),1,9999); shadow.AnchorPoint=Vector2.new(0.5,0.5); shadow.Position=UDim2.fromOffset(126,310); shadow.BackgroundTransparency=0.35
    local ring1=solid(panel,0,0,110,20,WHITE,1,9999); ring1.AnchorPoint=Vector2.new(0.5,0.5); ring1.Position=UDim2.fromOffset(126,310); ring1.BackgroundTransparency=1; local r1s=stroke(ring1,ACC,1.5,0.2); T(r1s,"Color")
    local ring2=solid(panel,0,0,110,20,WHITE,1,9999); ring2.AnchorPoint=Vector2.new(0.5,0.5); ring2.Position=UDim2.fromOffset(126,310); ring2.BackgroundTransparency=1; local r2s=stroke(ring2,ACC,1,0.6); T(r2s,"Color")
    local particles={}
    for i=1,12 do local f=solid(panel,0,0,2,2,WHITE,2); T(f,"BackgroundColor3"); particles[i]={f=f,x=math.random(12,238),y=math.random(40,330),sp=math.random(8,24),ph=math.random()*6} end
    local fovRing=solid(panel,0,0,100,100,WHITE,2,9999); fovRing.AnchorPoint=Vector2.new(0.5,0.5); fovRing.Position=UDim2.fromOffset(126,207); fovRing.BackgroundTransparency=1; fovRing.Visible=false; local fovS=stroke(fovRing,ACC,1,0.45)
    local tracerP=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),BorderSizePixel=0,Visible=false,ZIndex=2,Parent=panel})
    local spinL=new("TextLabel",{BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromOffset(196,66),Size=UDim2.fromOffset(30,30),Text="↻",Font=Enum.Font.GothamBold,TextSize=24,Visible=false,ZIndex=9,Parent=panel}); T(spinL,"TextColor3")

    local fig=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromOffset(126,207),Size=UDim2.fromOffset(90,170),BackgroundTransparency=1,Parent=panel})
    new("UIScale",{Scale=1.2,Parent=fig})
    local body=new("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Parent=fig})
    local function bf(x,y,w,h,col,z,r) return solid(body,x,y,w,h,col,z,r) end
    local trailF={}
    for k=1,14 do local f=bf(0,0,12,10,WHITE,1,3); f.AnchorPoint=Vector2.new(0.5,0.5); f.Visible=false; trailF[k]=f end
    local angelRows={{n=6,a0=6,a1=74,len=66,wd=9},{n=5,a0=18,a1=100,len=48,wd=8},{n=5,a0=28,a1=114,len=32,wd=8}}
    local wingA,wingD={{},{}},{{},{}}
    for side=1,2 do
        for ri,row in ipairs(angelRows) do for i=1,row.n do
            local f=bf(0,0,row.len,row.wd,WHITE,2,4); f.AnchorPoint=Vector2.new(0.5,0.5); f.Visible=false
            gradient(f,0,nil,NumberSequence.new({NumberSequenceKeypoint.new(0,0.05),NumberSequenceKeypoint.new(1,0.55)}))
            wingA[side][#wingA[side]+1]={f=f,row=ri,i=i,n=row.n,a0=row.a0,a1=row.a1,len=row.len}
        end end
        for i=1,26 do local f=bf(0,0,10,3,WHITE,2); f.AnchorPoint=Vector2.new(0.5,0.5); f.Visible=false; wingD[side][i]=f end
    end
    local ZONES={{n="Head",x=33,y=10,w=24,h=24,r=12,dx=45,dy=22},{n="Chest",x=27,y=40,w=36,h=32,r=4,dx=45,dy=56},{n="Stomach",x=30,y=72,w=30,h=20,r=3,dx=45,dy=82},
        {n="Left Arm",x=12,y=42,w=13,h=62,r=5,dx=18,dy=75},{n="Right Arm",x=65,y=42,w=13,h=62,r=5,dx=72,dy=75},{n="Left Leg",x=25,y=103,w=18,h=62,r=5,dx=34,dy=135},{n="Right Leg",x=47,y=103,w=18,h=62,r=5,dx=56,dy=135}}
    local overlays={}
    for _,z in ipairs(ZONES) do local ov=bf(z.x,z.y,z.w,z.h,ACC,4,z.r); ov.BackgroundTransparency=1; T(ov,"BackgroundColor3"); overlays[z.n]=ov end
    local segs={}
    local function seg(x,y,w,h,r)
        local f=bf(x,y,w,h,BODY_GRAY,3,r); gradient(f,90,ColorSequence.new(WHITE,Color3.fromRGB(122,126,132)))
        local s=new("UIStroke",{Thickness=1,Color=WHITE,Transparency=0.78,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=f}); segs[#segs+1]={f=f,s=s}
    end
    seg(33,10,24,24,12); seg(27,40,36,32,6); seg(30,72,30,20,4); seg(28,91,34,12,4)
    seg(13,42,12,32,6); seg(12,75,10,29,5); seg(10,105,9,9,4); seg(65,42,12,32,6); seg(68,75,10,29,5); seg(71,105,9,9,4)
    seg(26,103,17,36,6); seg(28,140,13,25,5); seg(24,165,19,5,2); seg(47,103,17,36,6); seg(49,140,13,25,5); seg(47,165,19,5,2)
    for _,j in ipairs({{27,46},{63,46},{19,77},{71,77},{35,104},{55,104},{34,140},{56,140}}) do seg(j[1]-3,j[2]-3,6,6,3) end
    local visor=bf(37,19,16,5,Color3.fromRGB(24,28,26),4,2); visor.BackgroundTransparency=0.15
    local emblem=new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(27,50),Size=UDim2.fromOffset(36,14),Font=F_HEAD,TextSize=8,TextTransparency=0.2,Text="LX",ZIndex=4,Parent=body}); T(emblem,"TextColor3")
    local skelF=new("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ZIndex=6,Visible=false,Parent=body})
    local J={head={45,22},neck={45,38},pel={45,98},shL={27,46},shR={63,46},elL={18,76},elR={72,76},haL={14,108},haR={76,108},hipL={35,104},hipR={55,104},knL={34,140},knR={56,140},ftL={34,166},ftR={56,166}}
    local BP={{"head","neck"},{"neck","pel"},{"neck","shL"},{"neck","shR"},{"shL","elL"},{"elL","haL"},{"shR","elR"},{"elR","haR"},{"pel","hipL"},{"pel","hipR"},{"hipL","knL"},{"knL","ftL"},{"hipR","knR"},{"knR","ftR"}}
    local skelParts={}
    for _,b in ipairs(BP) do skelParts[#skelParts+1]=lineF(skelF,J[b[1]][1],J[b[1]][2],J[b[2]][1],J[b[2]][2],2,WHITE,6) end
    for _,p in pairs(J) do skelParts[#skelParts+1]=solid(skelF,p[1]-2.5,p[2]-2.5,5,5,WHITE,7,3) end
    -- weapons (skin preview)
    local knifeB=bf(81,76,4,32,BODY_GRAY,7,2); knifeB.AnchorPoint=Vector2.new(0.5,1); knifeB.Position=UDim2.fromOffset(83,108); knifeB.Rotation=18
    local knifeH=bf(81,108,5,9,Color3.fromRGB(70,70,76),7); knifeH.Position=UDim2.fromOffset(80,108); knifeH.Rotation=18
    local knifeS=new("UIStroke",{Thickness=2,Transparency=1,Parent=knifeB})
    local gunB=bf(-6,102,24,7,BODY_GRAY,7,2); gunB.Rotation=-12; local gunG=bf(-2,108,6,11,BODY_GRAY,7,2); gunG.Rotation=-12
    local gunS=new("UIStroke",{Thickness=2,Transparency=1,Parent=gunB})
    -- ESP overlays
    local box2=bf(2,4,86,166,WHITE,8); box2.BackgroundTransparency=1; box2.Visible=false; local box2S=stroke(box2,WHITE,1.5,0)
    local cube={}
    for i=1,12 do local f=bf(0,0,2,2,WHITE,8); f.AnchorPoint=Vector2.new(0.5,0.5); f.Visible=false; cube[i]=f end
    local CE={{1,2},{3,4},{5,6},{7,8},{1,3},{2,4},{5,7},{6,8},{1,5},{2,6},{3,7},{4,8}}
    local function setCube(x,y,w,h,col,vis)
        local ox,oy=12,-9; local P={}; local i=0
        for _,sx in ipairs({0,1}) do for _,sy in ipairs({0,1}) do for _,sz in ipairs({0,1}) do i+=1; P[i]={x+sx*(w-ox)+sz*ox,y+(-oy)*(1-sz)+sy*(h+oy)} end end end
        for k,e in ipairs(CE) do local a,b=P[e[1]],P[e[2]]; local f=cube[k]; f.Visible=vis; if vis then setLine(f,a[1],a[2],b[1],b[2],2,col) end end
    end
    local function plabel(sz,txt) return new("TextLabel",{BackgroundTransparency=1,Size=UDim2.fromOffset(130,13),Font=F_MONO,TextSize=sz,Text=txt,TextStrokeTransparency=0.5,ZIndex=9,Visible=false,Parent=fig}) end
    local pRole,pName,pDist=plabel(10,"MURDERER"),plabel(9,"PLAYER"),plabel(8,"[42m]")
    local hpBg=bf(-5,4,3,166,Color3.new(0,0,0),8); hpBg.BackgroundTransparency=0.3; hpBg.Visible=false
    local hpFill=new("Frame",{AnchorPoint=Vector2.new(0,1),Position=UDim2.fromScale(0,1),Size=UDim2.fromScale(1,0.7),BackgroundColor3=Color3.fromRGB(90,230,110),BorderSizePixel=0,Parent=hpBg})
    -- hats
    local hatC={}
    local brim=bf(3,11,84,4,WHITE,5,2); brim.Visible=false; hatC[1]=brim
    for i=1,22 do local tt=(i-1)/21; local w=56*(1-tt)^1.3+3; local hf=bf(45-w/2,13-i*2,w,2,WHITE,5,1); hf.Visible=false; hatC[#hatC+1]=hf end
    local halo=bf(26,-6,38,9,WHITE,9,10); halo.BackgroundTransparency=1; halo.Visible=false; local haloS=stroke(halo,WHITE,2.5,0)
    local crown={}
    for i=1,7 do local f=bf(28+(i-1)*6,-2,5,i%2==0 and 12 or 8,WHITE,9,1); f.AnchorPoint=Vector2.new(0,1); f.Position=UDim2.fromOffset(28+(i-1)*6,5); f.Visible=false; crown[i]=f end
    local crownBase=bf(27,2,40,5,WHITE,9,1); crownBase.Visible=false
    -- aim dots / reticle
    local aimUI={}
    for _,z in ipairs(ZONES) do
        local b=new("TextButton",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromOffset(z.dx,z.dy),Size=UDim2.fromOffset(11,11),BackgroundColor3=Color3.fromRGB(230,235,232),BackgroundTransparency=0.45,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=12,Parent=body}); corner(b,6)
        local ds=stroke(b,WHITE,1,0.55); local u={z=z,b=b,s=ds,hover=false}
        b.MouseEnter:Connect(function() u.hover=true end); b.MouseLeave:Connect(function() u.hover=false end)
        b.MouseButton1Click:Connect(function() Setters.aimPart(z.n); Setters.silentPart(z.n) end)
        aimUI[#aimUI+1]=u
    end
    local aimAura=bf(0,0,26,26,ACC,12,14); aimAura.AnchorPoint=Vector2.new(0.5,0.5); aimAura.BackgroundTransparency=0.8; T(aimAura,"BackgroundColor3")
    local aimDot=bf(0,0,7,7,ACC,14,4); aimDot.AnchorPoint=Vector2.new(0.5,0.5); T(aimDot,"BackgroundColor3")
    local ret={}
    for i=1,4 do ret[i]=bf(0,0,i<=2 and 6 or 1,i<=2 and 1 or 6,ACC,14); ret[i].AnchorPoint=Vector2.new(0.5,0.5); T(ret[i],"BackgroundColor3") end

    local aimX,aimY,boxTop,flyOff,spinRot,tagAcc=45,22,4,0,0,0
    function X.previewStep(dt,t)
        local pulse=(math.sin(t*1.4)+1)/2
        local ecol=Flags.colorByRole and ROLE_COLORS.Murderer or colorOf(Flags.espCol,t)
        for i,g in ipairs(glow) do g.BackgroundColor3=ACC; g.BackgroundTransparency=0.955-i*0.006-pulse*0.01 end
        liveDot.BackgroundTransparency=pulse*0.7
        local ys=30+((t*0.33)%1)*300; scanLine.Position=UDim2.fromOffset(0,ys); scanBand.Position=UDim2.fromOffset(0,ys-38)
        local rp=(t*0.55)%1; ring2.Size=UDim2.fromOffset(90+rp*100,16+rp*26); r2s.Transparency=0.3+rp*0.7
        for _,p in ipairs(particles) do p.y-=p.sp*dt; if p.y<30 then p.y=338; p.x=math.random(12,238) end; p.f.Position=UDim2.fromOffset(p.x+math.sin(t*0.8+p.ph)*6,p.y); p.f.BackgroundTransparency=1-((p.y-30)/308)*0.55 end
        flyOff+=((Flags.fly and -16 or 0)-flyOff)*math.clamp(dt*8,0,1)
        body.Position=UDim2.fromOffset(0,math.sin(t*2)*1.5+flyOff); shadow.Size=UDim2.fromOffset(120+flyOff*2,22+flyOff*0.4)
        spinL.Visible=Flags.spin==true; if Flags.spin then spinRot+=dt*(60+Flags.spinSpeed*0.9); spinL.Rotation=spinRot%360 end
        -- hat / box top
        local hatOn=Flags.hat; local style=Flags.hatStyle
        boxTop+=((hatOn and style=="Chinese" and -36 or (hatOn and -10 or 4))-boxTop)*0.2
        local bh=170-boxTop; local b2,b3=Flags.box and Flags.boxStyle=="2D",Flags.box and Flags.boxStyle=="3D"
        box2.Visible=b2; box2.Position=UDim2.fromOffset(2,boxTop); box2.Size=UDim2.fromOffset(86,bh); box2S.Color=ecol
        setCube(2,boxTop+6,86,bh-6,ecol,b3)
        pRole.Visible=Flags.role==true; pRole.TextColor3=ROLE_COLORS.Murderer; pRole.Position=UDim2.fromOffset(-20,boxTop-26)
        pName.Visible=Flags.name==true; pName.TextColor3=ecol; pName.Position=UDim2.fromOffset(-20,boxTop-14)
        pDist.Visible=Flags.dist==true; pDist.TextColor3=WHITE; pDist.Position=UDim2.fromOffset(-20,173)
        hpBg.Visible=Flags.hp==true; hpBg.Position=UDim2.fromOffset(-5,boxTop); hpBg.Size=UDim2.fromOffset(3,bh); hpFill.Size=UDim2.fromScale(1,0.7+math.sin(t)*0.2)
        if Flags.tracer then setLine(tracerP,126+90,PH-34,126,306,1.2,ecol) else tracerP.Visible=false end
        skelF.Visible=Flags.skel==true; if Flags.skel then for _,s in ipairs(skelParts) do s.BackgroundColor3=ecol end end
        -- chams / glow
        local chams,glowOn=Flags.chams,Flags.glow; local cc,gc=colorOf(Flags.chamCol,t),colorOf(Flags.glowCol,t)
        for _,s in ipairs(segs) do
            if chams then s.f.BackgroundColor3,s.f.BackgroundTransparency=cc,math.clamp(Flags.chamTrans/100*0.6+(Flags.chamPulse and pulse*0.2 or 0),0,0.9) else s.f.BackgroundColor3,s.f.BackgroundTransparency=BODY_GRAY,0 end
            if glowOn then s.s.Color,s.s.Transparency,s.s.Thickness=gc,0.05+pulse*0.2,2 else s.s.Color,s.s.Transparency,s.s.Thickness=WHITE,0.78,1 end
        end
        visor.BackgroundColor3=chams and Color3.fromRGB(16,20,18) or Color3.fromRGB(24,28,26)
        -- hats
        for i,s in ipairs(hatC) do s.Visible=hatOn and style=="Chinese"; if s.Visible then s.BackgroundColor3=colorOf(Flags.hatCol,t,i*0.04) end end
        halo.Visible=hatOn and style=="Halo"; if halo.Visible then haloS.Color=colorOf(Flags.hatCol,t); halo.Position=UDim2.fromOffset(26,-8+math.sin(t*2)*2) end
        crownBase.Visible=hatOn and style=="Crown"; if crownBase.Visible then crownBase.BackgroundColor3=colorOf(Flags.hatCol,t) end
        for i,f in ipairs(crown) do f.Visible=hatOn and style=="Crown"; if f.Visible then f.BackgroundColor3=colorOf(Flags.hatCol,t,i*0.06) end end
        -- skins
        local kS,gS=X.SKIN_DATA[Flags.knifeSkin],X.SKIN_DATA[Flags.gunSkin]
        local kc=kS and X.skinColor(Flags.knifeSkin,t) or BODY_GRAY; local gcl=kS~=nil and gS and X.skinColor(Flags.gunSkin,t) or (gS and X.skinColor(Flags.gunSkin,t) or BODY_GRAY)
        knifeB.BackgroundColor3,gunB.BackgroundColor3,gunG.BackgroundColor3=kc,gcl,gcl:Lerp(Color3.new(0,0,0),0.35)
        knifeS.Color,gunS.Color=kc,gcl; knifeS.Transparency=(kS and kS.m==Enum.Material.Neon) and 0.35 or 1; gunS.Transparency=(gS and gS.m==Enum.Material.Neon) and 0.35 or 1
        -- wings
        local on,demon=Flags.wings,Flags.wingStyle=="Demon"; local flap=math.sin(t*Flags.wingSpeed)*9; local tint=colorOf(Flags.wingCol,t); local ws=Flags.wingSize/100
        for side=1,2 do
            local sg=side==1 and -1 or 1; local bx,by=45+sg*8,50
            for _,w in ipairs(wingA[side]) do
                if on and not demon then
                    local a=math.rad(w.a0+(w.a1-w.a0)*(w.i-1)/(w.n-1)+flap*(0.4+w.row*0.25)); local L=w.len*ws; local dx,dy=sg*math.cos(a),-math.sin(a)
                    w.f.Visible=true; w.f.Size=UDim2.fromOffset(L,w.f.Size.Y.Offset); w.f.Position=UDim2.fromOffset(bx+dx*L/2,by+dy*L/2); w.f.Rotation=math.deg(math.atan2(dy,dx)); w.f.BackgroundColor3=WHITE:Lerp(tint,({0.65,0.4,0.18})[w.row])
                else w.f.Visible=false end
            end
            local ln=wingD[side]
            if on and demon then
                local function P(x,y) return bx+sg*x*9*ws,by-(y+flap*0.05*x)*9*ws end
                local ox,oy=P(0,0); local ex,ey=P(1.5,1.9); local wx,wy=P(3.3,3.0)
                local tips={{P(4.6,5.8)},{P(6.4,4.4)},{P(6.8,2.1)},{P(5.5,0.1)},{P(3.4,-1.5)}}; local idx=1; local dark=Color3.fromRGB(34,5,10)
                local function L(x1,y1,x2,y2,th,col,tr) local f=ln[idx]; idx+=1; if f then setLine(f,x1,y1,x2,y2,th,col); f.BackgroundTransparency=tr end end
                for g=1,#tips-1 do for k=0,3 do if idx<=16 then L(wx,wy,tips[g][1]+(tips[g+1][1]-tips[g][1])*k/3,tips[g][2]+(tips[g+1][2]-tips[g][2])*k/3,6,dark:Lerp(tint,0.28),0.1) end end end
                idx=17; L(ox,oy,ex,ey,3,dark:Lerp(tint,0.5),0); L(ex,ey,wx,wy,2.5,dark:Lerp(tint,0.5),0)
                for _,tp in ipairs(tips) do if idx<=26 then L(wx,wy,tp[1],tp[2],1.8,tint,0) end end
                for i=idx,26 do ln[i].Visible=false end
            else for _,f in ipairs(ln) do f.Visible=false end end
        end
        -- trail
        local n=Flags.trail and math.clamp(math.floor(Flags.trailLen/30*14)+3,3,14) or 0
        for k,f in ipairs(trailF) do
            f.Visible=k<=n
            if k<=n then local fall=k/n; f.Position=UDim2.fromOffset(18-k*8,100+math.sin(t*4+k*0.6)*4*fall); f.Size=UDim2.fromOffset(12,math.max(2,Flags.trailWidth*2.4*(1-fall*0.85))); f.BackgroundTransparency=0.1+fall*0.85; f.BackgroundColor3=colorOf(Flags.trailCol,t,-k*0.04) end
        end
        -- aim
        fovRing.Visible=(Flags.aim and Flags.aimShowFov) and true or false
        if fovRing.Visible then local r=24+(Flags.aimFov-30)/570*94; fovRing.Size=UDim2.fromOffset(r*2,r*2); fovS.Color=colorOf(Flags.aimFovCol,t) end
        local sel=Flags.aimPart; local ap=(math.sin(t*5)+1)/2; local selZ
        for _,z in ipairs(ZONES) do if z.n==sel then selZ=z end end
        for nm,ov in pairs(overlays) do ov.BackgroundTransparency=(nm==sel) and (0.7-ap*0.15) or 1 end
        if selZ then local k=math.clamp(dt*9,0,1); aimX+=(selZ.dx-aimX)*k; aimY+=(selZ.dy-aimY)*k end
        aimDot.Position=UDim2.fromOffset(aimX,aimY); aimAura.Position=UDim2.fromOffset(aimX,aimY); aimAura.Size=UDim2.fromOffset(22+ap*8,22+ap*8)
        local g=7+ap*3
        ret[1].Position=UDim2.fromOffset(aimX-g-3,aimY); ret[2].Position=UDim2.fromOffset(aimX+g+3,aimY); ret[3].Position=UDim2.fromOffset(aimX,aimY-g-3); ret[4].Position=UDim2.fromOffset(aimX,aimY+g+3)
        for _,u in ipairs(aimUI) do
            if u.z.n==sel then u.b.BackgroundTransparency=1; u.s.Transparency=1
            elseif u.hover then u.b.BackgroundColor3=ACC; u.b.BackgroundTransparency=0.25; u.b.Size=UDim2.fromOffset(13,13); u.s.Transparency=0.2
            else u.b.BackgroundColor3=Color3.fromRGB(230,235,232); u.b.BackgroundTransparency=0.45; u.b.Size=UDim2.fromOffset(11,11); u.s.Transparency=0.55 end
        end
        aimCap.Text=Flags.aim and ("AIM / "..string.upper(tostring(sel))) or (Flags.silent and "SILENT / "..string.upper(tostring(Flags.silentPart)) or "AIM OFF")
        tagAcc+=dt
        if tagAcc>=0.3 then
            tagAcc=0; local tg={}
            local function add(k,nm) if Flags[k] then tg[#tg+1]=nm end end
            add("box","BOX"); add("role","ROLE"); add("name","NAME"); add("hp","HP"); add("dist","DIST"); add("tracer","TRC"); add("skel","SKEL"); add("chams","CHAMS"); add("glow","GLOW"); add("gunEsp","GUN")
            add("wings","WINGS"); add("hat","HAT"); add("trail","TRAIL"); add("fly","FLY"); add("spin","SPIN"); add("noclip","NC"); add("aim","AIM"); add("silent","SILENT"); add("autoWin","WIN"); add("farm","FARM")
            if Flags.knifeSkin~="Off" or Flags.gunSkin~="Off" then tg[#tg+1]="SKIN" end
            tagsL.Text=#tg>0 and table.concat(tg," / ") or "NO MODULES"
        end
    end
end
buildPreview()

-- =====================================================================
-- LOOPS / UNLOAD / START
-- =====================================================================
local fovC=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),BackgroundTransparency=1,Visible=false,Parent=espGui}); corner(fovC,500)
local fovCS=stroke(fovC,ACC,1.2,0.35)
local profAcc=0
local startTick=os.clock()

track(RunService.RenderStepped:Connect(function(dt)
    local cam=Workspace.CurrentCamera; local t=os.clock()
    if cam then
        X.espStep(cam,t); X.gunStep(cam,t); X.silentStep(cam,t)
        local show=Flags.aim and Flags.aimShowFov; fovC.Visible=show==true
        if show then local r=Flags.aimFov*2; fovC.Size=UDim2.fromOffset(r,r); fovCS.Color=colorOf(Flags.aimFovCol,t) end
    end
    X.fpsStep(dt)
    iconGrad.Rotation=(t*120)%360; iconGlow.Transparency=0.75+0.15*math.sin(t*2.5)
    iconL.Position=UDim2.new(0.5,-7,0.5,math.sin(t*3)*2.5); iconX.Position=UDim2.new(0.5,8,0.5,math.sin(t*3+math.pi)*2.5); iconX.Rotation=math.sin(t*2)*6
    brandS.Transparency=0.6+0.25*math.sin(t*2)
    if isOpen then
        mainGrad.Rotation=(t*45)%360
        X.previewStep(dt,t)
        profAcc+=dt
        if profAcc>=0.5 then
            profAcc=0
            local p=prof.view or LP; local L=prof.labels
            local s=math.floor(t-startTick); local ping=0
            pcall(function() ping=math.floor(StatsSvc.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            local role=getRoleCached(p)
            L.user.Text="USER      "..p.Name; L.id.Text="ID        "..p.UserId; L.age.Text="AGE       "..p.AccountAge.." days"
            L.role.Text="ROLE      "..role; L.team.Text="TEAM      "..(p.Team and p.Team.Name or "none"); L.ping.Text="PING      "..ping.." ms"
            L.session.Text=string.format("SESSION   %02d:%02d:%02d",math.floor(s/3600),math.floor((s%3600)/60),s%60)
            L.coins.Text="COINS     "..X.Farm.Collected; L.fps.Text="FPS       "..X.fps.cur.." | avg "..math.floor(X.fps.avg).." | max "..X.fps.max
            L.farm.Text="FARM      "..X.Farm.Status; L.aw.Text="AUTO WIN  "..X.AW.Status
        end
    end
    local myRole=getRoleCached(LP)
    footR.Text="ROLE  "..string.upper(myRole); footR.TextColor3=(myRole~="Innocent") and (ROLE_COLORS[myRole] or C.dim) or C.dim
end))
track(RunService.Heartbeat:Connect(function(dt)
    local t=os.clock(); local ok,ch,hum,hrp=isAlive(LP)
    if ok then X.charStep(dt,t,ch,hrp,hum); X.cosStep(dt,t,ch) end
    X.skinStep(dt,t)
end))

unload=function()
    Flags.silent=false; Flags.autoWin=false; Flags.farm=false; Flags.fly=false; Flags.spin=false; Flags.noclip=false
    pcall(function() RunService:UnbindFromRenderStep("luxxsAim") end)
    for _,c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    pcall(X.stopFarm); pcall(X.stopAW); pcall(X.charReset); pcall(X.cosRespawn); pcall(X.killAllEsp); pcall(X.killGun); pcall(X.skinRestore)
    pcall(X.disableShader,true); pcall(X.fpsRestore)
    if X.afkConn then X.afkConn:Disconnect() end
    gui:Destroy(); espGui:Destroy(); fpsGui:Destroy()
end

selectTab(aimTab)
refit()
applyAlpha()
loadAvatar()
if hasFS then
    pcall(function()
        local p=FOLDER.."/autoload.txt"
        if isfile(p) then local slot=readfile(p); if slot~="" and table.find(SLOTS,slot) then Setters.slot(slot); if isfile(cfgPath(slot)) then local ok,data=pcall(function() return HttpService:JSONDecode(readfile(cfgPath(slot))) end); if ok and type(data)=="table" then for k,v in pairs(data) do if Setters[k] and not EXCLUDE[k] then Setters[k](v) end end end end; Setters.autoload(true) end end
    end)
end
