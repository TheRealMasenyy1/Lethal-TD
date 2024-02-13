local animator = script.Parent:WaitForChild("Humanoid"):WaitForChild("Animator")
local animationObject = script.Parent:FindFirstChildOfClass("Animation")
local animation = animator:LoadAnimation(animationObject)
animation.Looped = true
animation:Play()