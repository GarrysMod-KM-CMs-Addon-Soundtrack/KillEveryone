require "DirectorClient"

if SERVER then return end

RegisterTrack( "MUS_KillEveryone_Start", "Music/KillEveryone/Start.wav" )
RegisterTrack( "MUS_KillEveryone_1", "Music/KillEveryone/1.wav" )
RegisterTrack( "MUS_KillEveryone_2", "Music/KillEveryone/2.wav" )
RegisterTrack( "MUS_KillEveryone_3", "Music/KillEveryone/3.wav" )
RegisterTrack( "MUS_KillEveryone_4", "Music/KillEveryone/4.wav" )
RegisterTrack( "MUS_KillEveryone_5", "Music/KillEveryone/5.wav" )
RegisterTrack( "MUS_KillEveryone_6", "Music/KillEveryone/6.wav" )
RegisterTrack( "MUS_KillEveryone_7", "Music/KillEveryone/7.wav" )
RegisterTrack( "MUS_KillEveryone_8", "Music/KillEveryone/8.wav" )
RegisterTrack( "MUS_KillEveryone_9", "Music/KillEveryone/9.wav" )
RegisterTrack( "MUS_KillEveryone_End", "Music/KillEveryone/End.wav" )

local tSongs = {
	"MUS_KillEveryone_1",
	"MUS_KillEveryone_2",
	"MUS_KillEveryone_3",
	"MUS_KillEveryone_4",
	"MUS_KillEveryone_5",
	"MUS_KillEveryone_6",
	"MUS_KillEveryone_7",
	"MUS_KillEveryone_8",
	"MUS_KillEveryone_9"
}

local random = math.random

local LoadTrack = LoadTrack
local StopMusic = StopMusic
local PlayMusic = PlayMusic

local math_Approach = math.Approach
local Lerp = Lerp

local SysTime = SysTime

DIRECTOR_ALLOCATE_COMBAT_THEME( "DIRECTOR_TRACK_KillEveryone", {
	CheckIntro = function( self ) return true end,
	Intro = function( self, flInterval, flVolumeA, flVolumeB, bCorrect )
		if !bCorrect then self.bFade = true end
		if self.bFade then
			if flVolumeB > 0 then
				flVolumeB = flVolumeB < .05 && math_Approach( flVolumeB, 0, flInterval ) || Lerp( .1 * flInterval, flVolumeB, 0 )
				return false, flVolumeA, flVolumeB
			end
			local flVolumeTransition = self.m_flVolume
			if flVolumeTransition > 0 then
				flVolumeTransition = flVolumeTransition < .05 && math_Approach( flVolumeTransition, 0, flInterval ) || Lerp( .1 * flInterval, flVolumeTransition, 0 )
				self.m_flVolume = flVolumeTransition
				return false, flVolumeA, flVolumeB
			end
			// We technically can't be DIRECTOR_THREAT_NULL (this is a combat track), but oh well
			if self.m_ELayerFrom == DIRECTOR_THREAT_NULL || flVolumeA >= 1 then return 0 end
			flVolumeA = flVolumeA > .95 && math_Approach( flVolumeA, 1, flInterval ) || Lerp( .1 * flInterval, flVolumeA, 1 )
			return false, flVolumeA, 0
		end
		LoadTrack "MUS_KillEveryone_End"
		local p = self.m_pSource
		p.m_pTable.Load( p )
		if !self.tHandles.Main then
			if self.bPartStarted then
				self.bPartStarted = nil
				StopMusic( self.m_pSource, "Main" )
				return true, 0, 1
			else
				self.m_pSource.sSong = nil
				PlayMusic( self, "Main", "MUS_KillEveryone_Start" )
				self.bPartStarted = true
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
		local sSong = tSongs[ random( 1, 9 ) ]
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
		local sSong = tSongs[ random( 1, 9 ) ]
		self.sSong = sSong
		LoadTrack( sSong )
	end
} )
