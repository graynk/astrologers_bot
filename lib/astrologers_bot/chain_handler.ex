defmodule AstrologersBot.ChainHandler do
  @moduledoc false

  use Telegex.Chain.Handler

  pipeline([
    AstrologersBot.RespStartChain,
    AstrologersBot.ChatPicChain,
    AstrologersBot.InlinePicChain
  ])
end
