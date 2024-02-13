local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage.Assets
local Viewports = Assets.Viewports
return {
	Part = {
		Name = "Part", --- USED TO IDENTIFY THE CORRECT SCRIPT TO USE -- balanced tower prices have a dps/$ ratio of around 0.09
		Summonable = false,
		Rarity = 5,
		Price = 0,
		MaxPlacement = 1,
		Image = "rbxassetid://157942893",
		Upgrades = {
			[0] = {
				Damage = 0,
				Cooldown = 0,
				Range = 0
			}
		},
		Tags = {}
	},

	Bird = { --- Use this(the one outside the table) name to save the units
		Name = "Bird", --- USED TO IDENTIFY THE CORRECT SCRIPT TO USE & SHOULD BE DISPLAYED TO THE PLAYERS
		Summonable = true,
		Rarity = 1,
        Price = 300,
        MaxPlacement = 20,
		Image = Viewports.Bird,
		Upgrades = {
			[0] = {
				Damage = 30,
				Cooldown = 1.5,
				Range = 30,
			},
			[1] = {
				Damage = 45,
				Cooldown = 1,
				Range = 40,
				Cost = 400
			},
			[2] = {
				Damage = 60,
				Cooldown = 1,
				Range = 50,
				Cost = 500
			}
		},
		Tags = {
		}
	},
	
	Slime = {
		Name = "Slime", --- USED TO IDENTIFY THE CORRECT SCRIPT TO USE
		Summonable = true,
		Rarity = 1,
		Price = 80,
		MaxPlacement = 20,
		Image = Viewports.Slime,
		Upgrades = {
			[0] = {
				Damage = 15,
				Cooldown = 2,
				Range = 20,
			},
			[1] = {
				Damage = 30,
				Cooldown = 2,
				Range = 25,
				Cost = 150
			},
			[2] = {
				Damage = 35,
				Cooldown = 1.7,
				Range = 25,
				Cost = 300
			},
			[3] = {
				Damage = 40,
				Cooldown = 1.2,
				Range = 25,
				Cost = 450
			}
		},
		Tags = {
		}
	},
	
	Rocket = {
		Name = "Rocket", --- USED TO IDENTIFY THE CORRECT SCRIPT TO USE
		Summonable = true,
		Rarity = 1,
		Price = 80,
		MaxPlacement = 20,
		Image = Viewports.R,
		Upgrades = {
			[0] = {
				Damage = 15,
				Cooldown = 2,
				Range = 20,
			},
			[1] = {
				Damage = 30,
				Cooldown = 2,
				Range = 25,
				Cost = 150
			},
			[2] = {
				Damage = 35,
				Cooldown = 1.7,
				Range = 25,
				Cost = 300
			},
			[3] = {
				Damage = 40,
				Cooldown = 1.2,
				Range = 25,
				Cost = 450
			}
		},
		Tags = {
		}
	},

	FuturisticToySoldier = {
		Name = "Futuristic ToySoldier", --- USED TO IDENTIFY THE CORRECT SCRIPT TO USE 
		Summonable = true,
		Rarity = 1,
		Price = 1800,
		MaxPlacement = 20,
		Image = Viewports.FuturisticToySoldier,
		Upgrades = {
			[0] = {
				Damage = 550,
				Cooldown = 3,
				Range = 30,
			},
			[1] = {
				Damage = 600,
				Cooldown = 2.5,
				Range = 40,
				Cost = 700
			},
			[2] = {
				Damage = 700,
				Cooldown = 2,
				Range = 50,
				Cost = 1000
			},
			[3] = {
				Damage = 800,
				Cooldown = 2,
				Range = 40,
				Cost = 1100 --4200
			},
			[4] = {
				Damage = 875,
				Cooldown = 2,
				Range = 40,
				Cost = 1200 --5400
			},
			[5] = {
				Damage = 900,
				Cooldown = 1.7,
				Range = 40,
				Cost = 1500 --6900
			},
			[6] = {
				Damage = 1000,
				Cooldown = 1.3,
				Range = 40,
				Cost = 2000 --8900
			}
		},
		Tags = {
		}
	},

	Jester = {
		Name = "Jester", --- USED TO IDENTIFY THE CORRECT SCRIPT TO USE
		Summonable = true,
		Rarity = 1,
		Price = 80,
		MaxPlacement = 20,
		Image = Viewports.Jester,
		Upgrades = {
			[0] = {
				Damage = 400,
				Cooldown = 3,
				Range = 30,
			},
			[1] = {
				Damage = 500,
				Cooldown = 2.5,
				Range = 40,
				Cost = 700
			},
			[2] = {
				Damage = 600,
				Cooldown = 2,
				Range = 50,
				Cost = 1000
			},
			[3] = {
				Damage = 750,
				Cooldown = 1.5,
				Range = 40,
				Cost = 1100 --4200
			},
			[4] = {
				Damage = 800,
				Cooldown = 1.3,
				Range = 40,
				Cost = 1200 --5400
			},
			[5] = {
				Damage = 850,
				Cooldown = 1.2,
				Range = 40,
				Cost = 1500 --6900
			},
			[6] = {
				Damage = 950,
				Cooldown = 1,
				Range = 40,
				Cost = 2000 --8900
			}
		},
		Tags = {
		}
	},

	CosmicThumper = {
		Name = "Cosmic Thumper", --- USED TO IDENTIFY THE CORRECT SCRIPT TO USE
		Summonable = true,
		Rarity = 1,
		Price = 1500,
		MaxPlacement = 20,
		Image = Viewports.CosmicThumper,
		Upgrades = {
			[0] = {
				Damage = 450,
				Cooldown = 3,
				Range = 20,
			},
			[1] = {
				Damage = 500,
				Cooldown = 2.5,
				Range = 25,
				Cost = 500
			},
			[2] = {
				Damage = 600,
				Cooldown = 2,
				Range = 25,
				Cost = 1000
			},
			[3] = {
				Damage = 750,
				Cooldown = 1.5,
				Range = 25,
				Cost = 2000
			},
			[4] = {
				Damage = 900,
				Cooldown = 1.5,
				Range = 25,
				Cost = 1000
			},
			[5] = {
				Damage = 950,
				Cooldown = 1.3,
				Range = 25,
				Cost = 2000
			},
			[6] = {
				Damage = 1100,
				Cooldown = 1,
				Range = 25,
				Cost = 5000
			}
		},
		Tags = {
		}
	},
	
	FireSpider = {
		Name = "Fire Spider", --- USED TO IDENTIFY THE CORRECT SCRIPT TO USE
		Summonable = true,
		Rarity = 1,
		Price = 800,
		MaxPlacement = 20,
		Image = Viewports.FireSpider,
		Upgrades = {
			[0] = {
				Damage = 200,
				Cooldown = 2,
				Range = 25,
			},
			[1] = {
				Damage = 250,
				Cooldown = 1.7,
				Range = 35,
				Cost = 400
			},
			[2] = {
				Damage = 260,
				Cooldown = 1.5,
				Range = 50,
				Cost = 500
			},

			[3] = {
				Damage = 270,
				Cooldown = 1,
				Range = 540,
				Cost = 750
			},
			[4] = {
				Damage = 290,
				Cooldown = 1,
				Range = 540,
				Cost = 750
			}
		},
		Tags = {
		}
	},

	Baboon = {
		Name = "Baboon", --- USED TO IDENTIFY THE CORRECT SCRIPT TO USE
		Summonable = true,
		Rarity = 1,
		Price = 400,
		MaxPlacement = 20,
		Image = Viewports.Baboon,
		Upgrades = {
			[0] = {
				Damage = 80,
				Cooldown = 2,
				Range = 20,
			},
			[1] = {
				Damage = 90,
				Cooldown = 1.7,
				Range = 40,
				Cost = 150
			},
			[2] = {
				Damage = 100,
				Cooldown = 1.5,
				Range = 50,
				Cost = 300
			},

			[3] = {
				Damage = 115,
				Cooldown = 1,
				Range = 540,
				Cost = 500
			}
		},
		Tags = {
		}
	},
	
	FireMonster = {
		Name = "Fire Monster", --- USED TO IDENTIFY THE CORRECT SCRIPT TO USE
		Summonable = true,
		Rarity = 1,
		Price = 80,
		MaxPlacement = 20,
		Image = Viewports.HellHound,
		Upgrades = {
			[0] = {
				Damage = 575,
				Cooldown = 3,
				Range = 30,
			},
			[1] = {
				Damage = 600,
				Cooldown = 2.5,
				Range = 40,
				Cost = 700
			},
			[2] = {
				Damage = 780,
				Cooldown = 2,
				Range = 50,
				Cost = 1000
			},
			[3] = {
				Damage = 875,
				Cooldown = 2,
				Range = 40,
				Cost = 1100 --4200
			},
			[4] = {
				Damage = 950,
				Cooldown = 2,
				Range = 40,
				Cost = 1200 --5400
			},
			[5] = {
				Damage = 1000,
				Cooldown = 1,7,
				Range = 40,
				Cost = 1500 --6900
			},
			[6] = {
				Damage = 1075,
				Cooldown = 1.3,
				Range = 40,
				Cost = 2000 --8900
			}
		},
		Tags = {
		}
	},

	
	Lizard = {
		Name = "Lizard", --- USED TO IDENTIFY THE CORRECT SCRIPT TO USE
		Summonable = true,
		Rarity = 1,
		Price = 560,
		MaxPlacement = 20,
		Image = Viewports.Lizard,
		Upgrades = {
			[0] = {
				Damage = 90,
				Cooldown = 2,
				Range = 30,
			},
			[1] = {
				Damage = 100,
				Cooldown = 1.5,
				Range = 40,
				Cost = 300
			},
			[2] = {
				Damage = 120,
				Cooldown = 1.3,
				Range = 50,
				Cost = 440
			},
			[3] = {
				Damage = 130,
				Cooldown = 1,
				Range = 50,
				Cost = 500
			},
			[4] = {
				Damage = 170,
				Cooldown = 1,
				Range = 50,
				Cost = 600
			}
		},
		Tags = {
		}
	},
	
	Thumper = {
		Name = "Thumper", --- USED TO IDENTIFY THE CORRECT SCRIPT TO USE
		Summonable = true,
		Rarity = 1,
		Price = 1500,
		MaxPlacement = 20,
		Image = Viewports.Thumper,
		Upgrades = {
			[0] = {
				Damage = 250,
				Cooldown = 2,
				Range = 30,
			},
			[1] = {
				Damage = 400,
				Cooldown = 2,
				Range = 40,
				Cost = 600
			},
			[2] = {
				Damage = 500,
				Cooldown = 1.5,
				Range = 50,
				Cost = 1000 --3100
			},
			[3] = {
				Damage = 500,
				Cooldown = 1,
				Range = 40,
				Cost = 1100 --4200
			},
			[4] = {
				Damage = 600,
				Cooldown = 1,
				Range = 40,
				Cost = 1500 --5400
			},
			[5] = {
				Damage = 675,
				Cooldown = 1,
				Range = 40,
				Cost = 1700 --6900
			},
			[6] = {
				Damage = 780,
				Cooldown = 1,
				Range = 40,
				Cost = 2000 --8900
			}
		},
		Tags = {
		}
	},
	
	ToySoldier = {
		Name = "Toy Soldier", --- USED TO IDENTIFY THE CORRECT SCRIPT TO USE
		Summonable = true,
		Rarity = 1,
		Price = 1400,
		MaxPlacement = 20,
		Image = Viewports.ToySoldier,
		Upgrades = {
			[0] = {
				Damage = 400,
				Cooldown = 3,
				Range = 30,
			},
			[1] = {
				Damage = 500,
				Cooldown = 2.5,
				Range = 40,
				Cost = 700
			},
			[2] = {
				Damage = 600,
				Cooldown = 2,
				Range = 50,
				Cost = 1000
			},
			[3] = {
				Damage = 750,
				Cooldown = 2,
				Range = 40,
				Cost = 1100 --4200
			},
			[4] = {
				Damage = 800,
				Cooldown = 2,
				Range = 40,
				Cost = 1200 --5400
			},
			[5] = {
				Damage = 850,
				Cooldown = 1,7,
				Range = 40,
				Cost = 1500 --6900
			},
			[6] = {
				Damage = 950,
				Cooldown = 1.3,
				Range = 40,
				Cost = 2000 --8900
			}
		},
		Tags = {
		}
	},
	
	Spider = {
		Name = "Spider", --- USED TO IDENTIFY THE CORRECT SCRIPT TO USE
		Summonable = true,
		Rarity = 1,
		Price = 700,
		MaxPlacement = 20,
		Image = Viewports.Spider,
		Upgrades = {
			[0] = {
				Damage = 130,
				Cooldown = 2,
				Range = 20,
			},
			[1] = {
				Damage = 170,
				Cooldown = 1,9,
				Range = 20,
				Cost = 300
			},
			[2] = {
				Damage = 240,
				Cooldown = 1.8,
				Range = 30,
				Cost = 500
			},
			[3] = {
				Damage = 300,
				Cooldown = 1.7,
				Range = 40,
				Cost = 700
			},
			[4] = {
				Damage = 310,
				Cooldown = 1,
				Range = 50,
				Cost = 800
			},
			[5] = {
				Damage = 400,
				Cooldown = 1,
				Range = 50,
				Cost = 1000
			}

		},
		Tags = {
		}
	},

	Monster = {
		Name = "Monster", --- USED TO IDENTIFY THE CORRECT SCRIPT TO USE
		Summonable = true,
		Rarity = 1,
		Price = 80,
		MaxPlacement = 20,
		Image = Viewports.Monster,
		Upgrades = {
			[0] = {
				Damage = 10,
				Cooldown = 1,
				Range = 30,
			},
			[1] = {
				Damage = 5,
				Cooldown = .3,
				Range = 40,
				Cost = 150
			},
			[2] = {
				Damage = 10,
				Cooldown = .2,
				Range = 50,
				Cost = 300
			}
		},
		Tags = {
		}
	},
	
	DollPilot = {
		Name = "Doll Pilot", --- USED TO IDENTIFY THE CORRECT SCRIPT TO USE
		Summonable = true,
		Rarity = 1,
		Price = 80,
		MaxPlacement = 20,
		Image = Viewports.DollPilot,
		Upgrades = {
			[0] = {
				Damage = 50,
				Cooldown = 3,
				Range = 20,
			},
			[1] = {
				Damage = 100,
				Cooldown = 2,
				Range = 40,
				Cost = 150
			},
			[2] = {
				Damage = 220,
				Cooldown = 1,
				Range = 50,
				Cost = 300
			}
		},
		Tags = {
		}
	},
	
	CosmicSpider = {
		Name = "Cosmic Spider",--- USED TO IDENTIFY THE CORRECT SCRIPT TO USE
		Summonable = true,
		Rarity = 1,
		Price = 750,
		MaxPlacement = 20,
		Image = Viewports.CosmicSpider,
		Upgrades = {
			[0] = {
				Damage = 150,
				Cooldown = 2,
				Range = 25,
			},
			[1] = {
				Damage = 200,
				Cooldown = 1.7,
				Range = 35,
				Cost = 400
			},
			[2] = {
				Damage = 210,
				Cooldown = 1.5,
				Range = 50,
				Cost = 500
			},

			[3] = {
				Damage = 240,
				Cooldown = 1,
				Range = 540,
				Cost = 750
			},
			[4] = {
				Damage = 270,
				Cooldown = 1,
				Range = 540,
				Cost = 750
			}
		},
		Tags = {
		}
	},
	
	CosmicBracken = {
		Name = "Cosmic Bracken",--- USED TO IDENTIFY THE CORRECT SCRIPT TO USE
		Summonable = true,
		Rarity = 1,
		Price = 1200,
		MaxPlacement = 20,
		Image = Viewports.CosmicBracken,
		Upgrades = {
			[0] = {
				Damage = 300,
				Cooldown = 2,
				Range = 30,
			},
			[1] = {
				Damage = 500,
				Cooldown = 2,
				Range = 40,
				Cost = 600
			},
			[2] = {
				Damage = 550,
				Cooldown = 1.5,
				Range = 50,
				Cost = 1000 --3100
			},
			[3] = {
				Damage = 550,
				Cooldown = 1,
				Range = 40,
				Cost = 1100 --4200
			},
			[4] = {
				Damage = 675,
				Cooldown = 1,
				Range = 40,
				Cost = 1500 --5400
			},
			[5] = {
				Damage = 700,
				Cooldown = 1,
				Range = 40,
				Cost = 1700 --6900
			},
			[6] = {
				Damage = 850,
				Cooldown = 1,
				Range = 40,
				Cost = 2000 --8900
			}
		},
		Tags = {
		}
	},
	
	CosmicHoard = {
		Name = "Cosmic Hoard",--- USED TO IDENTIFY THE CORRECT SCRIPT TO USE
		Summonable = true,
		Rarity = 1,
		Price = 600,
		MaxPlacement = 20,
		Image = Viewports.CosmicHoard,
		Upgrades = {
			[0] = {
				Damage = 60,
				Cooldown = 2,
				Range = 20,
			},
			[1] = {
				Damage = 85,
				Cooldown = 1.7,
				Range = 40,
				Cost = 150
			},
			[2] = {
				Damage = 90,
				Cooldown = 1.5,
				Range = 50,
				Cost = 300
			},

			[3] = {
				Damage = 100,
				Cooldown = 1,
				Range = 540,
				Cost = 500
			}
		},
		Tags = {
		}
	},
	
	CosmicGuardian = {
		Name = "Cosmic Guardian",--- USED TO IDENTIFY THE CORRECT SCRIPT TO USE
		Summonable = true,
		Rarity = 1,
		Price = 800,
		MaxPlacement = 20,
		Image = Viewports.CosmicGuardian,
		Upgrades = {
			[0] = {
				Damage = 175,
				Cooldown = 2,
				Range = 20,
			},
			[1] = {
				Damage = 230,
				Cooldown = 2,
				Range = 20,
				Cost = 300
			},
			[2] = {
				Damage = 300,
				Cooldown = 2,
				Range = 30,
				Cost = 500
			},
			[3] = {
				Damage = 340,
				Cooldown = 1.7,
				Range = 40,
				Cost = 700
			},
			[4] = {
				Damage = 390,
				Cooldown = 1.5,
				Range = 40,
				Cost = 800
			},
			[5] = {
				Damage = 500,
				Cooldown = 1.5,
				Range = 40,
				Cost = 1000
			}
		},
		Tags = {
		}
	},
	
	GearPilot = {
		Name = "Gear Pilot",--- USED TO IDENTIFY THE CORRECT SCRIPT TO USE
		Summonable = true,
		Rarity = 1,
		Price = 80,
		MaxPlacement = 20,
		Image = Viewports.GearPilot,
		Upgrades = {
			[0] = {
				Damage = 60,
				Cooldown = 3,
				Range = 25,
			},
			[1] = {
				Damage = 80,
				Cooldown = 2.5,
				Range = 40,
				Cost = 150
			},
			[2] = {
				Damage = 100,
				Cooldown = 2,
				Range = 50,
				Cost = 300
			},
			
			[3] = {
				Damage = 150,
				Cooldown = 1.5,
				Range = 50,
				Cost = 300
			}
		},
		Tags = {
		}
	},
	
	Pilot = {
		Name = "Pilot", --- USED TO IDENTIFY THE CORRECT SCRIPT TO USE
		Summonable = true,
		Rarity = 1,
		Price = 80,
		MaxPlacement = 20,
		Image = Viewports.Pilot,
		Upgrades = {
			[0] = {
				Damage = 10,
				Cooldown = 2,
				Range = 20,
			},
			[1] = {
				Damage = 20,
				Cooldown = 2,
				Range = 25,
				Cost = 150
			},
			[2] = {
				Damage = 25,
				Cooldown = 1.7,
				Range = 25,
				Cost = 300
			},
			[3] = {
				Damage = 40,
				Cooldown = 1.5,
				Range = 25,
				Cost = 450
			}
		},
		Tags = {
		}
	},

	
	StopsignPilot = {
		Name = "Stopsign Pilot", --- USED TO IDENTIFY THE CORRECT SCRIPT TO USE
		Summonable = true,
		Rarity = 1,
		Price = 80,
		MaxPlacement = 20,
		Image = Viewports.StopsignPilot,
		Upgrades = {
			[0] = {
				Damage = 20,
				Cooldown = 2,
				Range = 20,
			},
			[1] = {
				Damage = 30,
				Cooldown = 1,
				Range = 25,
				Cost = 150
			},
			[2] = {
				Damage = 40,
				Cooldown = .8,
				Range = 50,
				Cost = 300
			}
		},
		Tags = {
		}
	},
	
	ShotgunPilot = {
		Name = "Shotgun Pilot", --- USED TO IDENTIFY THE CORRECT SCRIPT TO USE
		Summonable = true,
		Rarity = 1,
		Price = 800,
		MaxPlacement = 20,
		Image = Viewports.ShotgunPilot,
		Upgrades = {
			[0] = {
				Damage = 150,
				Cooldown = 2,
				Range = 20,
			},
			[1] = {
				Damage = 200,
				Cooldown = 2,
				Range = 20,
				Cost = 300
			},
			[2] = {
				Damage = 275,
				Cooldown = 2,
				Range = 30,
				Cost = 500
			},
			[3] = {
				Damage = 300,
				Cooldown = 1.7,
				Range = 40,
				Cost = 700
			},
			[4] = {
				Damage = 350,
				Cooldown = 1.5,
				Range = 40,
				Cost = 800
			},
			[5] = {
				Damage = 500,
				Cooldown = 1.5,
				Range = 40,
				Cost = 1000
			}
		},
		Tags = {
		}
	},
	
	BoomboxPilot = { -- MODIFY TO BUFF TOWERS
		Name = "Boombox Pilot",  --- USED TO IDENTIFY THE CORRECT SCRIPT TO USE
		Summonable = true,
		Rarity = 1,
		Price = 80,
		MaxPlacement = 20,
		Image = Viewports.BoomboxPilot,
		Upgrades = {
			[0] = {
				Buff = 1.05,
				--Cooldown = 3,
				Range = 20,
			},
			[1] = {
				Buff = 1.10,
				--Cooldown = 2,
				Range = 40,
				Cost = 150
			},
			[2] = {
				Buff = 1.15,
				--Cooldown = 1,
				Range = 50,
				Cost = 300
			},
			[3] = {
				Buff = 1.20,
				--Cooldown = 1,
				Range = 50,
				Cost = 300
			},
			[4] = {
				Buff = 1.25,
				--Cooldown = 1,
				Range = 50,
				Cost = 300
			}
		},
		Tags = {
			"Buff"
		}
	},
	
	FlamethrowerPilot = {
		Name = "Flamethrower Pilot", --- USED TO IDENTIFY THE CORRECT SCRIPT TO USE
		Summonable = true,
		Rarity = 1,
		Price = 300,
		MaxPlacement = 20,
		Image = Viewports.FlamethrowerPilot,
		ReverseOrientation = true; 
		Upgrades = {
			[0] = {
				Damage = 50,
				Cooldown = 3,
				Range = 20,
			},
			[1] = {
				Damage = 75,
				Cooldown = 3,
				Range = 30,
				Cost = 250
			},
			[2] = {
				Damage = 100,
				Cooldown = 3,
				Range = 40,
				Cost = 300
			},
			[3] = {
				Damage = 100,
				Cooldown = 2,
				Range = 50,
				Cost = 400
			}
			
		},
		Tags = {
		}
	},
	
	ShovelPilot = {
		Name = "Shovel Pilot",  --- USED TO IDENTIFY THE CORRECT SCRIPT TO USE
		Summonable = true,
		Rarity = 1,
		Price = 80,
		MaxPlacement = 20,
		Image = Viewports.ShovelPilot,
		ReverseOrientation = true; 
		Upgrades = {
			[0] = {
				Damage = 130,
				Cooldown = 2,
				Range = 20,
			},
			[1] = {
				Damage = 175,
				Cooldown = 2,
				Range = 20,
				Cost = 300
			},
			[2] = {
				Damage = 275,
				Cooldown = 2,
				Range = 30,
				Cost = 500
			},
			[3] = {
				Damage = 320,
				Cooldown = 1.7,
				Range = 40,
				Cost = 700
			},
			[4] = {
				Damage = 375,
				Cooldown = 1.5,
				Range = 40,
				Cost = 800
			},
			[5] = {
				Damage = 575,
				Cooldown = 1.5,
				Range = 40,
				Cost = 1000
			}
		},
		Tags = {
		}
	},
	
	Bees = {
		Name = "Bees", --- USED TO IDENTIFY THE CORRECT SCRIPT TO USE
		Summonable = true,
		Rarity = 1,
		Price = 300,
		MaxPlacement = 20,
		Image = Viewports.Bees,
		ReverseOrientation = true; 
		Upgrades = {
			[0] = {
				Damage = 50,
				Cooldown = 2,
				Range = 20,
			},
			[1] = {
				Damage = 60,
				Cooldown = 1.7,
				Range = 40,
				Cost = 150
			},
			[2] = {
				Damage = 85,
				Cooldown = 1.5,
				Range = 50,
				Cost = 300
			},
			
			[3] = {
				Damage = 90,
				Cooldown = 1,
				Range = 70,
				Cost = 500
			}
		},
		Tags = {
		}
	},
	
	SprayPilot = {
		Name = "Spray Pilot",  --- USED TO IDENTIFY THE CORRECT SCRIPT TO USE
		Summonable = true,
		Rarity = 1,
		Price = 80,
		MaxPlacement = 20,
		Image = Viewports.SprayPilot,
		ReverseOrientation = true; 
		Upgrades = {
			[0] = {
				Slowness = 1,
				Cooldown = 3,
				Range = 20,
			},
			[1] = {
				Slowness = 1.5,
				Cooldown = 2,
				Range = 40,
				Cost = 150
			},
			[2] = {
				Slowness = 2,
				Cooldown = 1,
				Range = 50,
				Cost = 300
			}
		},
		Tags = {
		}
	},
	
	Guardian = {
		Name = "Guardian", --- USED TO IDENTIFY THE CORRECT SCRIPT TO USE
		Summonable = true,
		Rarity = 2,
		Price = 500,
		MaxPlacement = 20,
		Image = Viewports.Guardian,
		Upgrades = {
			[0] = {
				Damage = 100,
				Cooldown = 2,
				Range = 20,
			},
			
			[1] = {
				Damage = 150,
				Cooldown = 2,
				Range = 30,
				Cost = 150
			},
			[2] = {
				Damage = 250,
				Cooldown = 2,
				Range = 50,
				Cost = 300
			},
			
			[3] = {
				Damage = 300,
				Cooldown = 2,
				Range = 50,
				Cost = 300
			},
			
			[4] = {
				Damage = 350,
				Cooldown = 1.5,
				Range = 50,
				Cost = 300
			}

		},
		Tags = {
		}
	},
	
	Bracken = {
		Name = "Bracken", --- USED TO IDENTIFY THE CORRECT SCRIPT TO USE
		Summonable = true,
		Rarity = 2,
		Price = 200,
		MaxPlacement = 20,
		Image = Viewports.Bracken,
		Upgrades = {
			[0] = {
				Damage = 50,
				Cooldown = 1,
				Range = 20,
			},
			[1] = {
				Damage = 75,
				Cooldown = .8,
				Range = 40,
				Cost = 150
			},
			
			[2] = {
				Damage = 125,
				Cooldown = .7,
				Range = 50,
				Cost = 300
			},
			
			[3] = {
				Damage = 150,
				Cooldown = .7,
				Range = 50,
				Cost = 300
			},
			
			[4] = {
				Damage = 160,
				Cooldown = .6,
				Range = 50,
				Cost = 300
			}
		},
		Tags = {
		}
	},
	
	Girl = { -- This one should teleport when attacking
		Name = "Girl", --- USED TO IDENTIFY THE CORRECT SCRIPT TO USE
		Summonable = true,
		Rarity = 2,
		Price = 200,
		MaxPlacement = 20,
		Image = Viewports.Girl,
		Upgrades = {
			[0] = {
				Damage = 300,
				Cooldown = 3,
				Range = 30,
			},
			[1] = {
				Damage = 400,
				Cooldown = 2,
				Range = 40,
				Cost = 600
			},
			[2] = {
				Damage = 600,
				Cooldown = 1.5,
				Range = 50,
				Cost = 1000 --3100
			},
			[3] = {
				Damage = 650,
				Cooldown = 1,
				Range = 40,
				Cost = 1100 --4200
			},
			[4] = {
				Damage = 675,
				Cooldown = 1,
				Range = 40,
				Cost = 1500 --5400
			},
			[5] = {
				Damage = 800,
				Cooldown = 1,
				Range = 40,
				Cost = 1700 --6900
			},
			[6] = {
				Damage = 950,
				Cooldown = 1,
				Range = 40,
				Cost = 2000 --8900
			}
		},
		Tags = {
		}
	},
	
	Coil = {
		Name = "Coil", --- USED TO IDENTIFY THE CORRECT SCRIPT TO USE
		Summonable = true,
		Rarity = 2,
        Price = 200,
        MaxPlacement = 20,
		Image = Viewports.Coil,
		Upgrades = {
			[0] = {
				Damage = 500,
				Cooldown = 3,
				Range = 30,
			},
			[1] = {
				Damage = 600,
				Cooldown = 2.5,
				Range = 40,
				Cost = 700
			},
			[2] = {
				Damage = 750,
				Cooldown = 2,
				Range = 50,
				Cost = 1000
			},
			[3] = {
				Damage = 800,
				Cooldown = 2,
				Range = 40,
				Cost = 1100 --4200
			},
			[4] = {
				Damage = 875,
				Cooldown = 2,
				Range = 40,
				Cost = 1200 --5400
			},
			[5] = {
				Damage = 900,
				Cooldown = 1,7,
				Range = 40,
				Cost = 1500 --6900
			},
			[6] = {
				Damage = 1100,
				Cooldown = 1.3,
				Range = 40,
				Cost = 2000 --8900
			}
		},
		Tags = {
		}
	},
	Hoard = {
		Name = "Hoard", --- USED TO IDENTIFY THE CORRECT SCRIPT TO USE
		Summonable = true,
		Rarity = 2,
        Price = 600,
        MaxPlacement = 20,

		Image = Viewports.Hoard,
		Upgrades = {
			[0] = {
				Damage = 100,
				Cooldown = 2,
				Range = 25,
			},
			[1] = {
				Damage = 150,
				Cooldown = 1.7,
				Range = 35,
				Cost = 400
			},
			[2] = {
				Damage = 200,
				Cooldown = 1.5,
				Range = 50,
				Cost = 500
			},

			[3] = {
				Damage = 210,
				Cooldown = 1,
				Range = 50,
				Cost = 750
			},
			[4] = {
				Damage = 270,
				Cooldown = 1,
				Range = 50,
				Cost = 800
			}
		},
		Tags = {
		}
	},

	Worm = {
		Name = "Worm", --- USED TO IDENTIFY THE CORRECT SCRIPT TO USE
		Summonable = true,
		Rarity = 4,
        Price = 1500,
        MaxPlacement = 20,

		Image = Viewports.Worm,
		Upgrades = {
			[0] = {
				Damage = 1000,
				Cooldown = 4,
				Range = 50,
			},
			[1] = {
				Damage = 1200,
				Cooldown = 3.5,
				Range = 100,
				Cost = 500
			},
			[2] = {
				Damage = 1500,
				Cooldown = 3,
				Range = 150,
				Cost = 600
			},
			[3] = {
				Damage = 2000,
				Cooldown = 3,
				Range = 200,
				Cost = 1000
			},
			[4] = {
				Damage = 4000,
				Cooldown = 5.5,
				Range = 150,
				Cost = 600
			},
			[5] = {
				Damage = 5000,
				Cooldown = 5,
				Range = 200,
				Cost = 1000
			},
			[6] = {
				Damage = 6000,
				Cooldown = 4.5,
				Range = 150,
				Cost = 600
			}
		},
		Tags = {
			"AOE"
		}
	},
	
	Flea = {
		Name = "Flea", --- USED TO IDENTIFY THE CORRECT SCRIPT TO USE
		Summonable = true,
		Rarity = 1,
		Price = 400,
		MaxPlacement = 20,
		Image = Viewports.CosmicThumper,
		Upgrades = {
			[0] = {
				Damage = 60,
				Cooldown = 2,
				Range = 20,
			},
			[1] = {
				Damage = 70,
				Cooldown = 1.7,
				Range = 40,
				Cost = 150
			},
			[2] = {
				Damage = 90,
				Cooldown = 1.5,
				Range = 50,
				Cost = 300
			},

			[3] = {
				Damage = 140,
				Cooldown = 1,
				Range = 70,
				Cost = 500
			}
		},
		Tags = {
		}
	}
}