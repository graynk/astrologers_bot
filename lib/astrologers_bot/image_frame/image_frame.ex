defmodule AstrologersBot.ImageFrame do
  alias AstrologersBot.ImageFrame.Assets

  require Logger

  @moduledoc """
  Renders a framed image with text and OK button, which behaves kind of
  like a [NinePatchRect](https://docs.godotengine.org/en/stable/classes/class_ninepatchrect.html),
  except it's not elegant at all and the "nine" part of the NinePatchRect relates only to the frame.
  """

  @font_path Path.join("static", "font.ttf")
  @font_size 12
  @wrap_width 80
  @spacing 2

  @padding_side 15
  @padding_top 50
  @padding_bot 10

  @ok_button_vert_offset 45
  @min_dimension_pixels 100

  @max_width 4096
  @max_height 4096
  @max_dimension_sum 10_000
  @max_ratio 20

  @doc """
  Takes `text`, wraps it to `@wrap_width` symbols and returns the binary.
  """
  def get_image_bytes(text) do
    render_image!(text)
    |> Image.write!(:memory, suffix: ".png")
  end

  @doc """
  Takes `text`, wraps it to `@wrap_width` symbols and saves it into a PNG image with a random name.
  Returns the name of the file.
  """
  @spec write_image!(String.t()) :: String.t()
  def write_image!(text) do
    file_name = :crypto.hash(:md5, text) |> Base.encode16(case: :lower)
    # TODO: properly manage temp directories
    file_name = "/tmp/" <> file_name <> ".png"

    text
    |> render_image!()
    |> Image.write!(file_name)

    file_name
  end

  @spec render_image!(String.t()) :: Vix.Vips.Image.t()
  defp render_image!(text) do
    wrap_text!(text)
    |> render_text!()
    |> construct_frame!()
    |> fill_background!()
    |> add_ok_button!()
  end

  @spec wrap_text!(String.t()) :: String.t()
  defp wrap_text!(text) do
    Textwrap.fill(text, width: @wrap_width, break_words: false)
  end

  @spec calculate_image_size(Vix.Vips.Image.t()) ::
          {width :: pos_integer(), height :: pos_integer()}
  defp calculate_image_size(text_img) do
    text_w = Image.width(text_img)
    text_h = Image.height(text_img)

    side_borders_width = Image.width(Assets.get(:left)) + Image.width(Assets.get(:right))
    vert_borders_height = Image.height(Assets.get(:top)) + Image.height(Assets.get(:bot))

    ok_height = Image.height(Assets.get(:ok))

    ok_bot_offset = @ok_button_vert_offset + ok_height

    width =
      max(text_w + 2 * @padding_side + side_borders_width, @min_dimension_pixels)

    height =
      max(
        text_h + @padding_top + @padding_bot + vert_borders_height + ok_bot_offset,
        @min_dimension_pixels
      )

    # Telegram has a limit on max allowed image size and max allowed ration
    if width + height > @max_dimension_sum or width / height > @max_ratio do
      {@max_width, @max_height}
    else
      {width, height}
    end
  end

  @spec render_text!(String.t()) :: Vix.Vips.Image.t()
  defp render_text!(text) do
    Image.Text.text!(
      text,
      font: @font_path,
      font_size: @font_size,
      letter_spacing: @spacing,
      align: :center
    )
  end

  @spec construct_frame!(Vix.Vips.Image.t()) ::
          Vix.Vips.Image.t()
  defp construct_frame!(txt_img) do
    {target_width, target_height} = calculate_image_size(txt_img)
    corner_width = Image.width(Assets.get(:lt))
    corner_height = Image.height(Assets.get(:lt))
    vert_border_width = Image.width(Assets.get(:top))
    side_border_height = Image.height(Assets.get(:left))

    vert_border_count = ceil((target_width - 2 * corner_width) / vert_border_width)
    side_border_count = ceil((target_height - 2 * corner_height) / side_border_height)

    new_width = 2 * corner_width + vert_border_count * vert_border_width
    new_height = 2 * corner_height + side_border_count * side_border_height

    Logger.info("Generating image of size #{new_width}, #{new_height}")

    dst =
      Image.new!(new_width, new_height, bands: 4)
      |> Image.compose!(txt_img, x: :center, y: @padding_top)
      |> Image.compose!(Assets.get(:lt), x: :left, y: :top)
      |> Image.compose!(Assets.get(:rt), x: :right, y: :top)
      |> Image.compose!(Assets.get(:lb), x: :left, y: :bottom)
      |> Image.compose!(Assets.get(:rb), x: :right, y: :bottom)

    dst =
      Enum.reduce(0..(vert_border_count - 1), dst, fn i, acc ->
        x = corner_width + i * vert_border_width

        {:ok, img} =
          acc
          |> Image.compose!(Assets.get(:bot), x: x, y: :bottom)
          |> Image.compose!(Assets.get(:top), x: x, y: :top)
          # https://github.com/akash-akya/vix/issues/203#issuecomment-3530839006
          |> Vix.Vips.Image.copy_memory()

        img
      end)

    Enum.reduce(0..(side_border_count - 1), dst, fn i, acc ->
      y = corner_height + i * side_border_height

      {:ok, img} =
        acc
        |> Image.compose!(Assets.get(:left), x: :left, y: y)
        |> Image.compose!(Assets.get(:right), x: :right, y: y)
        # https://github.com/akash-akya/vix/issues/203#issuecomment-3530839006
        |> Vix.Vips.Image.copy_memory()

      img
    end)
  end

  @spec fill_background!(Vix.Vips.Image.t()) ::
          Vix.Vips.Image.t()
  defp fill_background!(frame) do
    w = Image.width(frame)
    h = Image.height(frame)

    fill_w = Image.width(Assets.get(:fill))
    fill_h = Image.height(Assets.get(:fill))

    dst = Image.new!(w, h, bands: 4)

    # Tile fill pattern inside the inner area
    dst =
      Enum.reduce(0..h//fill_h, dst, fn y, acc_y ->
        Enum.reduce(0..w//fill_w, acc_y, fn x, acc_x ->
          {:ok, img} =
            Image.compose!(acc_x, Assets.get(:fill), x: x, y: y)
            # https://github.com/akash-akya/vix/issues/203#issuecomment-3530839006
            |> Vix.Vips.Image.copy_memory()

          img
        end)
      end)

    Image.compose!(dst, frame)
  end

  @spec add_ok_button!(Vix.Vips.Image.t()) ::
          Vix.Vips.Image.t()
  defp add_ok_button!(image) do
    height = Image.height(image)
    y = height - @ok_button_vert_offset - Image.height(Assets.get(:ok))
    Image.compose!(image, Assets.get(:ok), x: :center, y: y)
  end
end
