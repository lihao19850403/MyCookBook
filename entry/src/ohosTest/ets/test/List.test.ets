import abilityTest from './Ability.test';
import MenuTest from './Menu.test';
import MineTest from './Mine.test';
import NewsTest from './News.test';
import SocializeTest from './Socialize.test';

export default function testsuite() {
  abilityTest();
  NewsTest();
  MenuTest();
  SocializeTest();
  MineTest();
}