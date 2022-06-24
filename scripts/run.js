const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory("ElfGame");
  const gameContract = await gameContractFactory.deploy(
    ["Gojo Satoru", "Megumi Fushiguro", "Itadori Yuji"], // Names
    [
      "https://c4.wallpaperflare.com/wallpaper/787/854/424/jujutsu-kaisen-satoru-gojo-anime-boys-anime-girls-hd-wallpaper-preview.jpg", // Images
      "https://c4.wallpaperflare.com/wallpaper/529/774/554/anime-megumi-fushiguro-jujutsu-kaisen-hd-wallpaper-preview.jpg",
      "https://c4.wallpaperflare.com/wallpaper/158/122/422/anime-anime-boys-jujutsu-kaisen-yuji-itadori-sakuna-hd-wallpaper-preview.jpg",
    ],
    [1000, 2000, 2500], // HP values
    [1000, 3000, 2500], // Attack damage values
    "Mahito",
    "https://static.wikia.nocookie.net/jujutsu-kaisen/images/4/4e/Mahito_%28Anime%29.png/revision/latest/scale-to-width-down/700?cb=20201025153259",
    100000,
    500
  );
  await gameContract.deployed();
  console.log("Contract deployed to:", gameContract.address);
  let txn;
  txn = await gameContract.mintCharacter(2);
  await txn.wait();

  txn = await gameContract.attackVillain();
  await txn.wait();

  txn = await gameContract.attackVillain();
  await txn.wait();
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
};

runMain();
