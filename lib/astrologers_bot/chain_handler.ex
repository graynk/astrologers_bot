defmodule AstrologersBot.ChainHandler do
  @moduledoc false

  use Telegex.Chain.Handler

  pipeline([
    AstrologersBot.RespStartChain,
    AstrologersBot.RespPingChain,
    AstrologersBot.EchoTextChain,
    AstrologersBot.CallHelloChain
  ])
end
