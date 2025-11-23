defmodule AstrologersBot.ImageFrame.ImageFrameTest do
  use ExUnit.Case, async: false

  @fixtures Path.join(["test", "astrologers_bot", "image_frame", "fixtures"])

  defp hash(binary) do
    :crypto.hash(:md5, binary) |> Base.encode16(case: :lower)
  end

  defp text_to_image_hash(input) do
    Path.join([@fixtures, "#{input}.txt"])
    |> File.read!()
    |> String.trim()
    |> AstrologersBot.ImageFrame.get_image_bytes()
    |> hash()
  end

  defp image_to_hash(input) do
    Path.join([@fixtures, "#{input}.png"])
    |> File.read!()
    |> hash()
  end

  test "should generate small image with default size" do
    input = "small"
    assert text_to_image_hash(input) == image_to_hash(input)
  end

  test "should generate image with non-English symbols" do
    input = "russian_text"
    assert text_to_image_hash(input) == image_to_hash(input)
  end

  test "should do line-break on big text blocks" do
    input = "small_lorem_ipsum"
    assert text_to_image_hash(input) == image_to_hash(input)
  end

  test "should support big multi-block texts" do
    input = "big_lorem_ipsum"
    assert text_to_image_hash(input) == image_to_hash(input)
  end
end
