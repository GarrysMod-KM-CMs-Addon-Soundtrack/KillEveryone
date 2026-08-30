require "DirectorClient"

if SERVER then return end

RegisterTrack( "MUS_KillEveryone_Start", "Music/KillEveryone/Start.wav" )
RegisterTrack( "MUS_KillEveryone_StartAlt", "Music/KillEveryone/StartAlt.wav" )
RegisterTrack( "MUS_KillEveryone_End", "Music/KillEveryone/End.wav" )

RegisterTrack( "MUS_KillEveryone_StartShort1", "Music/KillEveryone/StartShort1.wav" )
RegisterTrack( "MUS_KillEveryone_StartShort2", "Music/KillEveryone/StartShort2.wav" )
RegisterTrack( "MUS_KillEveryone_StartShort3", "Music/KillEveryone/StartShort3.wav" )

RegisterTrack( "MUS_KillEveryone_Main_StartPart", "Music/KillEveryone/Main/StartPart.wav" )
RegisterTrack( "MUS_KillEveryone_Main_1", "Music/KillEveryone/Main/1.wav" )
RegisterTrack( "MUS_KillEveryone_Main_2", "Music/KillEveryone/Main/2.wav" )
RegisterTrack( "MUS_KillEveryone_Main_3", "Music/KillEveryone/Main/3.wav" )
RegisterTrack( "MUS_KillEveryone_Main_4", "Music/KillEveryone/Main/4.wav" )
RegisterTrack( "MUS_KillEveryone_Main_5", "Music/KillEveryone/Main/5.wav" )
RegisterTrack( "MUS_KillEveryone_Main_5StraightIntoIt", "Music/KillEveryone/Main/5StraightIntoIt.wav" )
RegisterTrack( "MUS_KillEveryone_Main_6", "Music/KillEveryone/Main/6.wav" )
RegisterTrack( "MUS_KillEveryone_Main_7", "Music/KillEveryone/Main/7.wav" )
RegisterTrack( "MUS_KillEveryone_Main_7x5", "Music/KillEveryone/Main/7x5.wav" )
RegisterTrack( "MUS_KillEveryone_Main_8", "Music/KillEveryone/Main/8.wav" )
RegisterTrack( "MUS_KillEveryone_Main_9", "Music/KillEveryone/Main/9.wav" )

RegisterTrack( "MUS_KillEveryone_Continue_1", "Music/KillEveryone/Continue/1.wav" )
RegisterTrack( "MUS_KillEveryone_Continue_2", "Music/KillEveryone/Continue/2.wav" )
RegisterTrack( "MUS_KillEveryone_Continue_3", "Music/KillEveryone/Continue/3.wav" )
RegisterTrack( "MUS_KillEveryone_Continue_4", "Music/KillEveryone/Continue/4.wav" )
RegisterTrack( "MUS_KillEveryone_Continue_5", "Music/KillEveryone/Continue/5.wav" )
RegisterTrack( "MUS_KillEveryone_Continue_6", "Music/KillEveryone/Continue/6.wav" )

local SONGS = {
	"MUS_KillEveryone_Main_StartPart",
	"MUS_KillEveryone_Main_1",
	"MUS_KillEveryone_Main_2",
	"MUS_KillEveryone_Main_3",
	"MUS_KillEveryone_Main_4",
	"MUS_KillEveryone_Main_5",
	"MUS_KillEveryone_Main_5StraightIntoIt",
	"MUS_KillEveryone_Main_6",
	"MUS_KillEveryone_Main_7",
	"MUS_KillEveryone_Main_7x5",
	"MUS_KillEveryone_Main_8",
	"MUS_KillEveryone_Main_9"
}

local NUM_SONGS = #SONGS


local CONTINUES = {
	"MUS_KillEveryone_Continue_1",
	"MUS_KillEveryone_Continue_2",
	"MUS_KillEveryone_Continue_3",
	"MUS_KillEveryone_Continue_4",
	"MUS_KillEveryone_Continue_5",
	"MUS_KillEveryone_Continue_6"
}

local NUM_CONTINUES = #CONTINUES


local SHORTSTARTS = {
	"MUS_KillEveryone_StartShort1",
	"MUS_KillEveryone_StartShort2",
	"MUS_KillEveryone_StartShort3"
}

local NUM_SHORTSTARTS = #SHORTSTARTS


local random = math.random

local LoadTrack = LoadTrack
local StopMusic = StopMusic
local PlayMusic = PlayMusic

local math_Approach = math.Approach

local SysTime = SysTime

DIRECTOR_ALLOCATE_COMBAT_THEME( "DIRECTOR_TRACK_KillEveryone", {
	CheckIntro = function( self ) return true end,
	Intro = function( self, flInterval, flVolumeA, flVolumeB, bCorrect )
		if !bCorrect then self.bFade = true end
		if self.bFade then
			if flVolumeB > 0 then
				flVolumeB = math_Approach( flVolumeB, 0, flInterval )
				return false, flVolumeA, flVolumeB
			end
			local flVolumeTransition = self.m_flVolume
			if flVolumeTransition > 0 then
				flVolumeTransition = math_Approach( flVolumeTransition, 0, flInterval )
				self.m_flVolume = flVolumeTransition
				return false, flVolumeA, flVolumeB
			end
			// We technically can't be DIRECTOR_THREAT_NULL (this is a combat track), but oh well
			if self.m_ELayerFrom == DIRECTOR_THREAT_NULL || flVolumeA >= 1 then return 0 end
			flVolumeA = math_Approach( flVolumeA, 1, flInterval )
			return false, flVolumeA, 0
		end

		LoadTrack "MUS_KillEveryone_End"

		local p = self.m_pSource
		p.m_pTable.Load( p )

		if !self.tHandles.Main then
			StopMusic( self.m_pSource, "Main" )

			if self.bPartStarted then
				self.bPartStarted = nil
				return true, 0, 1
			else
				if random( 4 ) == 1 then return true, 0, 1 end

				self.bPartStarted = true
				self.m_pSource.sSong = nil

				if random( 2 ) == 1 then
					PlayMusic( self, "Main", SHORTSTARTS[ random( 1, NUM_SHORTSTARTS ) ] )
				else
					PlayMusic( self, "Main", random( 2 ) == 1 && "MUS_KillEveryone_StartAlt" || "MUS_KillEveryone_Start" )
				end
			end
		end

		return nil, 0, 0
	end,

	CheckOutro = function( self ) return true end,
	Outro = function( self, flInterval, flVolumeA, flVolumeB, bCorrect )
		local p = self.m_pSource
		// Wait til the handle finishes
		p.flOutroTime = SysTime() + .1
		if p.tHandles.Main then return nil, 1, 0 end
		p.m_pTable.Load( p )
		if !self.tHandles.Main then
			if self.bPartStarted then
				self.bPartStarted = nil
				StopMusic( self.m_pSource, "Main" )
				return bCorrect, 0, 1
			else
				self.m_pSource.sSong = nil
				PlayMusic( self, "Main", "MUS_KillEveryone_End" )
				self.bPartStarted = true
			end
		end
		return nil, 0, 0
	end,

	Load = function( self )
		if self.sSong then return end
		local sSong = SONGS[ random( 1, NUM_SONGS ) ]
		self.sSong = sSong
		LoadTrack( sSong )
	end,

	Execute = function( self )
		LoadTrack "MUS_KillEveryone_End"
		local flOutroTime = self.flOutroTime
		if flOutroTime && SysTime() <= flOutroTime then return end
		if self.m_flVolume <= 0 then StopMusic( self, "Main" ) return end
		if self.tHandles.Main then return end
		// This prolly can't happen lmao, as sSong will almost always be valid
		PlayMusic( self, "Main", self.sSong || "MUS_KillEveryone_1" )
		// Warm up the next stem so it's ready to roll
		// This prevents us from warming up all nine (which Source hates),
		// only warming up one track, plus lets us keep the randomness
		local sSong = SONGS[ random( 1, NUM_SONGS ) ]
		self.sSong = sSong
		LoadTrack( sSong )
	end
} )
